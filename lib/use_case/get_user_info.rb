module UseCase
  class GetUserInfo
    def initialize(user_credentials_gateway:)
      @user_credentials_gateway = user_credentials_gateway
    end

    def execute(user_id)
      @user_credentials_gateway.get_user_info(user_id)
    end
  end
end
