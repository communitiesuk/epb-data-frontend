module Controller
  class OptOutController < BaseController
    get "/opt-out" do
      status 200
      set_default
      erb :'opt_out/start'
    end

    get "/opt-out/reason" do
      status 200
      set_default

      erb :'opt_out/reason'
    rescue StandardError => e
      server_error(e)
    end

    post "/opt-out/reason" do
      set_default
      case params["reason"]
      when "epc_incorrect"
        redirect localised_url("/opt-out/incorrect-epc")
      when "epc_advised"
        redirect localised_url("/opt-out/advised-by-third-party")
      when "epc_other"
        redirect localised_url("/opt-out/owner")
      else
        @error_form_ids << "reason-error"
        @errors[:reason] = t("opt_out.reason.error.invalid_reason_selection.heading")
        erb :'opt_out/reason'
      end
    end

    get "/opt-out/incorrect-epc" do
      status 200
      set_default
      @back_link_href = "/opt-out/reason"
      erb :'opt_out/incorrect_epc'
    end

    get "/opt-out/advised-by-third-party" do
      status 200
      set_default
      @back_link_href = "/opt-out/reason"
      erb :'opt_out/advised_by_third_party'
    end

    get "/opt-out/owner" do
      status 200
      set_default
      @back_link_href = "/opt-out/reason"
      erb :'opt_out/owner'
    end

    post "/opt-out/owner" do
      set_default
      case params["owner"]
      when "yes"
        Helper::Session.set_session_value(session, :opt_out, { owner: "yes" })
        redirect "/login?referer=/opt-out"
      when "no"
        Helper::Session.set_session_value(session, :opt_out, { owner: "no" })
        redirect "/opt-out/occupant"
      else
        @error_form_ids << "owner-error"
        @errors[:owner] = t("opt_out.owner.error")
        erb :'opt_out/owner'
      end
    end

    get "/opt-out/ineligible" do
      status 200
      set_default
      erb :'opt_out/ineligible'
    end

    def set_default
      @errors = {}
      @error_form_ids = []
      @hide_my_account = true
    end
  end
end
