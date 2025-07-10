module Helper
  class Session
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
