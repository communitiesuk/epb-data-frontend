module Controller
  class ApiController < Controller::BaseController
    include Helper::ReferrerCheck

    get "/api/my-account/toggle-email-notifications" do
      toggle_email_notifications_use_case = @container.get_object(:toggle_email_notifications_use_case)
      user_id = Helper::Session.get_session_value(session, :user_id)
      toggle_email_notifications_use_case.execute(user_id)
      redirect "/api/my-account"
    end

    get "/api/my-account" do
      status 200
      @back_link_href = request.referer || "/"
      @page_title = "#{t('my_account.title')} – #{t('layout.body.govuk')}"

      get_user_info_use_case = @container.get_object(:get_user_info_use_case)

      user_id = Helper::Session.get_session_value(session, :user_id)
      user_info = get_user_info_use_case.execute(user_id)

      erb :my_account, locals: { user_info: }
    rescue StandardError => e
      case e
      when Errors::BearerTokenMissing
        logger.warn "Bearer token missing: #{e.message}"
        redirect "/login/authorize?referer=api/my-account"
      when Errors::UserMissing
        logger.warn "User information from user-credentials missing: #{e.message}"
        redirect "/login/authorize?referer=api/my-account"
      else
        server_error(e)
      end
    end

    get "/api/my-account/delete-account" do
      @back_link_href = request.referer || "/api/my-account"
      @page_title = "#{t('delete_account.title')} – #{t('layout.body.govuk')}"
      erb :delete_account
    rescue StandardError => e
      server_error(e)
    end

    post "/api/my-account/delete-account" do
      id_token_hint = session["id_token"]
      @container.get_object(:delete_user_use_case).execute(id_token_hint)
      session.clear
      state = SecureRandom.uuid
      session["delete_state"] = state
      post_logout_redirect_uri = uri("/account-deleted")
      redirect Helper::Onelogin.sign_out_url(id_token_hint:, post_logout_redirect_uri:, state:)
    rescue StandardError => e
      server_error(e)
    end

    get "/account-deleted" do
      return redirect "/" unless params["state"] == session["delete_state"]

      session.clear
      @page_title = "#{t('delete_account.account_deleted')} – #{t('layout.body.govuk')}"
      erb :account_deleted
    rescue StandardError => e
      server_error(e)
    end
  end
end
