module UseCase
  class AddBearerToken
    def initialize(user_credentials_gateway:)
      @user_credentials_gateway = user_credentials_gateway
    end

    def execute(user_id:)
      raise Errors::UserMissing if user_id.nil?

      begin
        tokens = @user_credentials_gateway.get_user_tokens(user_id)
      rescue Errors::BearerTokenMissing
        tokens = []
      end

      if tokens.count >= 2
        raise Errors::BearerTokenLimitExceeded, "Users cannot have more than 2 bearer tokens"
      end

      @user_credentials_gateway.add_bearer_token(user_id:)
    end
  end
end
