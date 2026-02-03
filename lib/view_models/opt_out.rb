module ViewModels
  class OptOut
    def self.get_full_name_from_session(session)
      Helper::Session.get_session_value(session, :opt_out_name)
    end

    def self.get_email_from_session(session)
      Helper::Session.get_email_from_session(session)
    end

    def self.get_certificate_number_from_session(session)
      Helper::Session.get_session_value(session, :opt_out_certificate_number)
    end

    def self.get_address_detail_from_session(session, key)
      Helper::Session.get_session_value(session, key)
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

      if owner == "yes"
        "Owner"
      elsif occupant == "yes"
        "Occupant"
      end
    end
  end
end
