class Helper::ValidateSession
  def initialize(session)
    @session = session
  end

  def validate_full_name_from_session
    full_name = Helper::Session.get_session_value(@session, :opt_out_name)

    if full_name.nil?
      raise Errors::MissingOptOutValues, "Failed to get full name from session opt out key. Full name is nil."
    end
  end

  def validate_certificate_number_from_session
    certificate_number = Helper::Session.get_session_value(@session, :opt_out_certificate_number)

    if certificate_number.nil?
      raise Errors::MissingOptOutValues, "Failed to get certificate number from session opt out key. Certificate number is nil."
    end
  end

  def validate_address_from_session(key)
    address_detail = Helper::Session.get_session_value(@session, key)

    if %i[opt_out_address_line1 opt_out_address_postcode].include?(key) && address_detail.nil?
      raise Errors::MissingOptOutValues, "Failed to get #{key} from session. #{key.to_s.split('_').map(&:capitalize).join(' ')} is nil."
    end
  end

  def validate_email_from_session
    email = Helper::Session.get_email_from_session(@session)

    if email.nil?
      raise Errors::MissingOptOutValues, "Failed to get email address from session opt out key. Email address is nil."
    end
  end

  def validate_relationship_to_the_property
    owner = Helper::Session.get_session_value(@session, :opt_out_owner)
    occupant = Helper::Session.get_session_value(@session, :opt_out_occupant)

    unless occupant == "yes" || owner == "yes"
      raise Errors::MissingOptOutValues, "Failed to get relationship to the property from session opt out key. Both owner and occupant values are nil."
    end
  end

  def validate_missing_opt_out_session
    validate_full_name_from_session
    validate_certificate_number_from_session
    validate_address_from_session(:opt_out_address_line1)
    validate_address_from_session(:opt_out_address_line2)
    validate_address_from_session(:opt_out_address_town)
    validate_address_from_session(:opt_out_address_postcode)
    validate_relationship_to_the_property
    validate_email_from_session
  end
end
