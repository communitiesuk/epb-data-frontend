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
  end
end
