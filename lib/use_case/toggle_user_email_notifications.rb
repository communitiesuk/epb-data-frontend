module UseCase
  class ToggleUserEmailNotifications
    def initialize(user_credentials_gateway:)
      @user_credentials_gateway = user_credentials_gateway
    end

    def execute(user_id)
      @user_credentials_gateway.toggle_user_opt_out(user_id)
    end
  end
end
