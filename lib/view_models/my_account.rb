module ViewModels
  class MyAccount
    def self.get_email_address(session)
      Helper::Session.get_email_from_session(session)
    end

    def self.get_bearer_token(session, use_case)
      user_id = Helper::Session.get_session_value(session, :user_id)
      use_case.execute(user_id)
    end
  end
end
