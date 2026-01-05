module ViewModels
  class OptOut
    def self.get_full_name_from_session(session)
      full_name = Helper::Session.get_session_value(session, :opt_out_name)

      if full_name.nil?
        raise Errors::MissingOptOutValues, "Failed to get full name from session opt out key. Full name is nil."
      end

      full_name
    end

    def self.get_email_from_session(session)
      email = Helper::Session.get_email_from_session(session)

      if email.nil?
        raise Errors::MissingOptOutValues, "Failed to get email address from session opt out key. Email address is nil."
      end

      email
    end

    def self.get_certificate_number_from_session(session)
      certificate_number = Helper::Session.get_session_value(session, :opt_out_certificate_number)

      if certificate_number.nil?
        raise Errors::MissingOptOutValues, "Failed to get certificate number from session opt out key. Certificate number is nil."
      end

      certificate_number
    end

    def self.get_address_detail_from_session(session, key)
      address_detail = Helper::Session.get_session_value(session, key)

      if %i[opt_out_address_line1 opt_out_address_postcode].include?(key) && address_detail.nil?
        raise Errors::MissingOptOutValues, "Failed to get #{key} from session. #{key.to_s.split('_').map(&:capitalize).join(' ')} is nil."
      end

      address_detail
    end

    def self.get_form_value(params, session, key)
      session_key = "opt_out_#{key}"
      Helper::Session.get_session_value(session, session_key.to_sym)
      if !params[key].nil?
        params[key]
      elsif !Helper::Session.get_session_value(session, session_key.to_sym).nil?
        get_address_detail_from_session(session, session_key.to_sym)
      else
        ""
      end
    end

    def self.get_relationship_to_the_property(session)
      owner = Helper::Session.get_session_value(session, :opt_out_owner)
      occupant = Helper::Session.get_session_value(session, :opt_out_occupant)
      if (occupant.nil? && owner.nil?) || (owner == "no" && occupant == "no")
        raise Errors::MissingOptOutValues, "Failed to get relationship to the property from session opt out key. Both owner and occupant values are nil."
      end

      if owner == "yes"
        "Owner"
      elsif occupant == "yes"
        "Occupant"
      end
    end
  end
end
