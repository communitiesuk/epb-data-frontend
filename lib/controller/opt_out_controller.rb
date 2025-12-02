module Controller
  class OptOutController < BaseController
    get "/opt-out" do
      status 200
      set_layout
      erb :'opt_out/start'
    end

    get "/opt-out/reason" do
      status 200
      set_layout
      @errors = {}
      erb :'opt_out/reason'
    rescue StandardError => e
      server_error(e)
    end

    post "/opt-out/reason" do
      @errors = {}
      @error_form_ids = []
      if params["reason"]
        # redirect "/opt_out/reason=#{params['reason']}"
      else
        @error_form_ids << "reason-error"
        @errors[:reason] = t("opt_out.reason.error.invalid_reason_selection.heading")
        erb :'opt_out/reason'
      end
    end

    get "/opt-out/incorrect-epc" do
      status 200
      set_layout
      @back_link_href = "/opt-out/reason"
      erb :'opt_out/incorrect_epc'
    end

    get "/opt-out/advised-by-third-party" do
      status 200
      set_layout
      @back_link_href = "/opt-out/reason"
      erb :'opt_out/advised_by_third_party'
    end

    def set_layout
      @hide_my_account = true
    end
  end
end
