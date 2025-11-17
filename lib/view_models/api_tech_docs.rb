module ViewModels
  class ApiTechDocs < ViewModels::FilterProperties
    def self.get_bearer_token(session, use_case)
      user_id = Helper::Session.get_session_value(session, :user_id)
      use_case.execute(user_id)
    end
  end
end
