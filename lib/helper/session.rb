module Helper
  class Session
    def self.set_local(session)
      unless ENV["LOCAL_SESSION"].nil?
        session[:email_address] = "test@example.com"
      end
      nil
    end

    def self.set_session_value(session, key, value)
      session[key] = value
    end

    def self.exists?(session, key)
      session.key?(key)
    end

    def self.get_session_value(session, key)
      session[key] if exists?(session, key)
    end

    def self.clear_session(session)
      session.clear
    end

    def self.get_email_from_session(session)
      email = get_session_value(session, :email_address)
      raise Errors::AuthenticationError, "Failed to get user email from session" unless email

      email
    end

    def self.get_full_name_from_session(session)
      opt_out_key = get_session_value(session, :opt_out)
      opt_out_key[:name]
    end

    def self.get_owner_from_opt_out_session_key(session)
      opt_out_key = get_session_value(session, :opt_out)
      opt_out_key[:owner]
    end

    def self.get_occupant_from_opt_out_session_key(session)
      opt_out_key = get_session_value(session, :opt_out)
      opt_out_key[:occupant]
    end

    def self.get_certificate_number_from_session(session)
      opt_out_key = get_session_value(session, :opt_out)
      opt_out_key[:certificate_number]
    end

    def self.get_opt_out_session_value(session, key)
      opt_out_key = get_session_value(session, :opt_out)
      opt_out_key[key]
    end

    def self.is_user_authenticated?(session)
      raise Errors::AuthenticationError, "Session is not available" if session.nil?

      email = get_session_value(session, :email_address)
      raise Errors::AuthenticationError, "User email is not set in session" if email.nil? || email.empty?

      true
    end

    def self.is_logged_in?(session)
      return false if session.nil?

      email = get_session_value(session, :email_address)
      return false if email.nil? || email.empty?

      true
    end
  end
end
