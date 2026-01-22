require "rack/protection"

module Controller
  class OptOutController < BaseController
    include Helper::OptOut

    get "/opt-out" do
      status 200
      set_default
      erb :'opt_out/start'
    rescue StandardError => e
      server_error(e)
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
        Helper::Session.set_session_value(session, :opt_out_incorrect_epc, true)
        redirect localised_url("/opt-out/incorrect-epc")
      when "epc_advised"
        Helper::Session.set_session_value(session, :opt_out_advised_epc, true)
        redirect localised_url("/opt-out/advised-by-third-party")
      when "epc_other"
        Helper::Session.set_session_value(session, :opt_out_other_reason, true)
        redirect localised_url("/opt-out/owner")
      else
        @error_form_ids << "reason-error"
        @errors[:reason] = t("opt_out.reason.error.invalid_reason_selection.heading")
        erb :'opt_out/reason'
      end
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/incorrect-epc" do
      status 200
      set_default
      incorrect_epc = Helper::Session.get_session_value(session, :opt_out_incorrect_epc)

      if incorrect_epc.nil?
        redirect localised_url("/opt-out")
      end

      @back_link_href = localised_url("/opt-out/reason")
      erb :'opt_out/incorrect_epc'
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/advised-by-third-party" do
      status 200
      set_default
      advised_by_third_party = Helper::Session.get_session_value(session, :opt_out_advised_epc)

      if advised_by_third_party.nil?
        redirect localised_url("/opt-out")
      end

      @back_link_href = localised_url("/opt-out/reason")
      erb :'opt_out/advised_by_third_party'
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/owner" do
      status 200
      set_default
      other_reason = Helper::Session.get_session_value(session, :opt_out_other_reason)

      if other_reason.nil?
        redirect localised_url("/opt-out")
      end

      @back_link_href = localised_url("/opt-out/reason")
      Helper::Session.delete_session_key(session, :opt_out_owner)
      Helper::Session.delete_session_key(session, :opt_out_occupant)
      erb :'opt_out/owner'
    rescue StandardError => e
      server_error(e)
    end

    post "/opt-out/owner" do
      set_default
      case params["owner"]
      when "yes"
        Helper::Session.set_session_value(session, :opt_out_owner, "yes")
        redirect localised_url("/login?referer=opt-out")
      when "no"
        Helper::Session.set_session_value(session, :opt_out_owner, "no")
        redirect localised_url("/opt-out/occupant")
      else
        @error_form_ids << "owner-error"
        @errors[:owner] = t("opt_out.owner.error")
        erb :'opt_out/owner'
      end
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/ineligible" do
      status 200
      set_default
      erb :'opt_out/ineligible'
    rescue StandardError => e
      server_error(e)
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
      when "yes"
        Helper::Session.set_session_value(session, :opt_out_occupant, "yes")
        redirect localised_url("/login?referer=opt-out")
      when "no"
        Helper::Session.set_session_value(session, :opt_out_occupant, "no")
        redirect localised_url("/opt-out/ineligible")
      else
        @error_form_ids << "occupant-error"
        @errors[:occupant] = t("opt_out.occupant.error.invalid_occupant_selection.heading")
        erb :'opt_out/occupant'
      end
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/name" do
      status 200
      set_default
      owner = Helper::Session.get_session_value(session, :opt_out_owner)
      occupant = Helper::Session.get_session_value(session, :opt_out_occupant)

      if owner.nil? && occupant.nil?
        redirect localised_url("/opt-out")
      end

      unless owner == "yes" || occupant == "yes"
        redirect localised_url("/opt-out/ineligible")
      end

      erb :'opt_out/name'
    end

    post "/opt-out/name" do
      set_default
      name = params["name"].strip
      if name.empty?
        @error_form_ids << "name-error"
        @errors[:name] = t("opt_out.name.error.empty")
      elsif name.length > 255
        @error_form_ids << "name-error"
        @errors[:name] = t("opt_out.name.error.too_long")
      end

      if @errors.empty?
        Helper::Session.set_session_value(session, :opt_out_name, name)
        redirect localised_url("/opt-out/certificate-details")
      else
        erb :'opt_out/name'
      end
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/certificate-details" do
      owner = Helper::Session.get_session_value(session, :opt_out_owner)
      occupant = Helper::Session.get_session_value(session, :opt_out_occupant)
      name = Helper::Session.get_session_value(session, :opt_out_name)

      if owner.nil? && occupant.nil?
        redirect localised_url("/opt-out")
      end

      unless owner == "yes" || occupant == "yes"
        redirect localised_url("/opt-out/ineligible")
      end

      unless name
        redirect localised_url("/opt-out/name")
      end

      status 200
      set_default
      erb :'opt_out/certificate_details'
    end

    post "/opt-out/certificate-details" do
      set_default
      extract_certificate_params

      validate_certificate_number
      validate_address_line1
      validate_address_line2
      validate_address_town
      validate_address_postcode

      if @errors.empty?
        save_opt_out_session
        redirect localised_url("/opt-out/check-your-answers")
      else
        erb :'opt_out/certificate_details'
      end
    rescue StandardError => e
      server_error(e)
    end

    get "/opt-out/check-your-answers" do
      status 200
      set_default
      erb :'opt_out/check_your_answers'
    rescue StandardError => e
      case e
      when Errors::AuthenticationError
        logger.warn "Authentication error: #{e.message}"
        redirect localised_url("/login?referer=opt-out")
      when Errors::MissingOptOutValues
        @logger.warn "Session values are missing when reaching /opt-out/check-your-answers: #{e.message}"
        redirect localised_url("/opt-out")
      else
        server_error(e)
      end
    end

    post "/opt-out/check-your-answers" do
      set_default

      if params["confirmation"] == "checked"
        name = Helper::Session.get_session_value(session, :opt_out_name)
        certificate_number = Helper::Session.get_session_value(session, :opt_out_certificate_number)
        address_line1 = Helper::Session.get_session_value(session, :opt_out_address_line1)
        address_line2 = Helper::Session.get_session_value(session, :opt_out_address_line2)
        town = Helper::Session.get_session_value(session, :opt_out_address_town)
        postcode = Helper::Session.get_session_value(session, :opt_out_address_postcode)
        owner = Helper::Session.get_session_value(session, :opt_out_owner)
        occupant = Helper::Session.get_session_value(session, :opt_out_occupant)
        email = Helper::Session.get_email_from_session(session)

        owner_or_occupier = if owner == "yes"
                              "Owner"
                            elsif occupant == "yes"
                              "Occupant"
                            end

        use_case = @container.get_object(:send_opt_out_request_email_use_case)
        max_retries = 3
        max_retries.times do
          use_case.execute(name:, certificate_number:, address_line1:, address_line2:, town:, postcode:, email:, owner_or_occupier:)
          break
        rescue Errors::NotifyServerError
          nil
        end

        redirect localised_url("/opt-out/received")
      else
        @error_form_ids << "confirmation-error"
        @errors[:confirmation] = t("opt_out.check_your_answers.confirmation.error")
        erb :'opt_out/check_your_answers'
      end
    rescue StandardError, Errors::NotifySendEmailError => e
      server_error(e)
    end

    get "/opt-out/received" do
      status 200
      set_default
      session_keys = %i[opt_out_owner opt_out_occupant opt_out_name opt_out_certificate_number opt_out_address_line1 opt_out_address_line2 opt_out_address_town opt_out_address_postcode]
      session_keys.each do |session_key|
        Helper::Session.delete_session_key(session, session_key)
      end

      erb :'opt_out/received'
    rescue StandardError => e
      server_error(e)
    end

    def set_default
      @errors = {}
      @error_form_ids = []
      @hide_my_account = true
    end
  end
end
