module ViewModels
  class OptOut
    def self.get_full_name_from_session(session)
      Helper::Session.get_full_name_from_session(session)
    end

    def self.get_email_from_session(session)
      Helper::Session.get_email_from_session(session)
    end

    def self.get_certificate_number_from_session(session)
      Helper::Session.get_certificate_number_from_session(session)
    end

    def self.get_relationship_to_the_property(session)
      owner = Helper::Session.get_owner_from_opt_out_session_key(session)
      occupant = Helper::Session.get_occupant_from_opt_out_session_key(session)

      if occupant.nil? && owner.nil?
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
