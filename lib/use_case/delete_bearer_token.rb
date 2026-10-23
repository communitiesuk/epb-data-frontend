module UseCase
  class DeleteBearerToken
    def initialize(user_credentials_gateway:)
      @user_credentials_gateway = user_credentials_gateway
    end

    def execute(user_id:, bearer_token:)
      raise Errors::UserMissing if user_id.nil?
      raise Errors::BearerTokenMissing if bearer_token.nil? || bearer_token.to_s.strip.empty?

      tokens = @user_credentials_gateway.get_user_tokens(user_id)
      if tokens.count <= 1
        raise Errors::CannotDeleteLastBearerToken, "Users must have at least one bearer token"
      end

      raise Errors::BearerTokenNotFound, "Bearer token not found" unless tokens.include?(bearer_token)

      @user_credentials_gateway.delete_bearer_token(user_id:, bearer_token: bearer_token)
    end
  end
end
