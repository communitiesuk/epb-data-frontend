module Controller
  class ApiController < Controller::BaseController
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
      else
        logger.error "Unexpected error during /api/my-account get endpoint: #{e.message}"
        server_error(e)
      end
    end
  end
end
