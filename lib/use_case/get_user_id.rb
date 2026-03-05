module UseCase
  class GetUserId
    def initialize(user_credentials_gateway:)
      @user_credentials_gateway = user_credentials_gateway
    end

    def execute(one_login_sub:, email:)
      user_id = @user_credentials_gateway.get_user(one_login_sub)
      if user_id.nil?
        @user_credentials_gateway.insert_user(one_login_sub:, email:)
      else
        @user_credentials_gateway.update_user_email(user_id:, email:)
        user_id
      end
    end
  end
end
