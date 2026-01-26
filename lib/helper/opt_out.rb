module Helper
  module OptOut
    def extract_certificate_params
      @certificate_number = params["certificate_number"].to_s.strip
      @address_line1 = params["address_line1"].to_s.strip
      @address_line2 = params["address_line2"].to_s.strip
      @address_town = params["address_town"].to_s.strip
      @address_postcode = params["address_postcode"].to_s.strip
    end

    def validate_certificate_number
      if @certificate_number.empty? || !certificate_valid(@certificate_number)
        @error_form_ids << "certificate-number-error"
        @errors[:certificate_number] = t("opt_out.certificate_details.certificate_number.error")
      end
    end

    def validate_address_line1
      if @address_line1.empty?
        @error_form_ids << "address-line1-error"
        @errors[:address_line1] = t("opt_out.certificate_details.address_line1.error")
      elsif @address_line1.length > 255
        @error_form_ids << "address-line1-error"
        @errors[:address_line1] = t("opt_out.certificate_details.address_line1.too_long_error")
      end
    end

    def validate_address_line2
      if @address_line2.length > 255
        @error_form_ids << "address-line2-error"
        @errors[:address_line2] = t("opt_out.certificate_details.address_line2.too_long_error")
      end
    end

    def validate_address_town
      if @address_town.length > 255
        @error_form_ids << "address-town-error"
        @errors[:address_town] = t("opt_out.certificate_details.town.too_long_error")
      end
    end

    def validate_address_postcode
      if @address_postcode.empty?
        @error_form_ids << "address-postcode-error"
        @errors[:address_postcode] = t("opt_out.certificate_details.postcode.error")
      else
        begin
          Helper::PostcodeValidator.validate(@address_postcode)
        rescue Errors::PostcodeIncomplete, Errors::PostcodeWrongFormat, Errors::PostcodeNotValid
          @error_form_ids << "address-postcode-error"
          @errors[:address_postcode] = t("opt_out.certificate_details.postcode.error")
        end
      end
    end

    def save_opt_out_session
      Helper::Session.set_session_value(session, :opt_out_certificate_number, @certificate_number)
      Helper::Session.set_session_value(session, :opt_out_address_line1, @address_line1)
      Helper::Session.set_session_value(session, :opt_out_address_line2, @address_line2)
      Helper::Session.set_session_value(session, :opt_out_address_town, @address_town)
      Helper::Session.set_session_value(session, :opt_out_address_postcode, @address_postcode)
    end

    def get_owner_or_occupier_from_session(session)
      owner = Helper::Session.get_session_value(session, :opt_out_owner)
      occupant = Helper::Session.get_session_value(session, :opt_out_occupant)

      if owner == "yes"
        "Owner"
      elsif occupant == "yes"
        "Occupant"
      end
    end

    def get_opt_out_details_from_session(session)
      {
        name: Helper::Session.get_session_value(session, :opt_out_name),
        certificate_number: Helper::Session.get_session_value(session, :opt_out_certificate_number),
        address_line1: Helper::Session.get_session_value(session, :opt_out_address_line1),
        address_line2: Helper::Session.get_session_value(session, :opt_out_address_line2),
        town: Helper::Session.get_session_value(session, :opt_out_address_town),
        postcode: Helper::Session.get_session_value(session, :opt_out_address_postcode),
        email: Helper::Session.get_email_from_session(session),
        owner_or_occupier: get_owner_or_occupier_from_session(session),
      }
    end

    def send_opt_out_email_with_retries(container:, details:)
      use_case = container.get_object(:send_opt_out_request_email_use_case)

      max_retries = 3
      max_retries.times do
        use_case.execute(**details)
        break
      rescue Errors::NotifyServerError
        nil
      end
    end

    def certificate_valid(rrn)
      valid_rrn = "^(\\d{4}-){4}\\d{4}$".freeze
      rrn.to_s.delete("-").length == 20 && Regexp.new(valid_rrn).match?(rrn)
    end
  end
end
