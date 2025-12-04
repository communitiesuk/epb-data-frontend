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
        redirect localised_url("/login?referer=opt-out")
      when "no"
        Helper::Session.set_session_value(session, :opt_out, { owner: "no" })
        redirect localised_url("/opt-out/occupant")
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

    get "/opt-out/occupant" do
      status 200
      set_default
      @errors = {}
      erb :'opt_out/occupant'
    rescue StandardError => e
      server_error(e)
    end

    post "/opt-out/occupant" do
      set_default
      case params["occupant"]
      when "occupant_yes"
        Helper::Session.set_session_value(session, :opt_out, { occupant: "yes" })
        redirect localised_url("/login?referer=opt-out")
      when "occupant_no"
        Helper::Session.set_session_value(session, :opt_out, { occupant: "no" })
        redirect localised_url("/opt-out/ineligible")
      else
        @error_form_ids << "occupant-error"
        @errors[:occupant] = t("opt_out.occupant.error.invalid_occupant_selection.heading")
        erb :'opt_out/occupant'
      end
    end

    get "/opt-out/name" do
      status 200
      set_default
      erb :'opt_out/name'
    end

    post "/opt-out/name" do
      set_default
      name = params["name"].strip
      if name.empty?
        @error_form_ids << "name-error"
        @errors[:name] = t("opt_out.name.error")
        erb :'opt_out/name'
      else
        opt_out_session = Helper::Session.get_session_value(session, :opt_out)
        opt_out_session[:name] = name
        Helper::Session.set_session_value(session, :opt_out, opt_out_session)
        redirect "/opt-out/certificate-details"
      end
    end

    get "/opt-out/certificate-details" do
      status 200
      set_default
      erb :'opt_out/certificate_details'
    end

    post "/opt-out/certificate-details" do
      set_default
      certificate_number = params["certificate_number"].strip
      address_line1 = params["address_line1"].strip
      address_line2 = params["address_line2"].strip
      address_town = params["address_town"].strip
      address_postcode = params["address_postcode"].strip

      if certificate_number.empty? || !certificate_valid(certificate_number)
        @error_form_ids << "certificate-number-error"
        @errors[:certificate_number] = t("opt_out.certificate_details.certificate_number.error")
      end

      if address_line1.empty?
        @error_form_ids << "address-line1-error"
        @errors[:address_line1] = t("opt_out.certificate_details.address_line1.error")
      end

      if address_postcode.empty?
        @error_form_ids << "address-postcode-error"
        @errors[:address_postcode] = t("opt_out.certificate_details.postcode.error")
      else
        begin
          Helper::PostcodeValidator.validate(address_postcode)
        rescue Errors::PostcodeIncomplete, Errors::PostcodeWrongFormat, Errors::PostcodeNotValid
          @error_form_ids << "address-postcode-error"
          @errors[:address_postcode] = t("opt_out.certificate_details.postcode.error")
        end
      end

      if @errors.empty?
        opt_out_session = Helper::Session.get_session_value(session, :opt_out) || {}
        opt_out_session[:certificate_number] = certificate_number
        opt_out_session[:address_line1] = address_line1
        opt_out_session[:address_line2] = address_line2
        opt_out_session[:address_town] = address_town
        opt_out_session[:address_postcode] = address_postcode
        Helper::Session.set_session_value(session, :opt_out, opt_out_session)
        redirect "/opt-out/check-your-answers"
      else
        erb :'opt_out/certificate_details'
      end
    end

    get "/opt-out/check-your-answers" do
      status 200
      set_default
      erb :'opt_out/check_your_answers'
    end

    get "/opt-out/received" do
      status 200
      set_default
      erb :'opt_out/received'
    end

    def set_default
      @errors = {}
      @error_form_ids = []
      @hide_my_account = true
    end

    def certificate_valid(rrn)
      valid_rrn = "^(\\d{4}-){4}\\d{4}$".freeze
      rrn.delete("-").length == 20 && Regexp.new(valid_rrn).match?(rrn)
    end
  end
end
