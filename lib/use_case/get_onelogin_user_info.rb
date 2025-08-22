module UseCase
  class GetOneloginUserInfo
    def initialize(onelogin_gateway:)
      @onelogin_gateway = onelogin_gateway
    end

    def execute(access_token:)
      @onelogin_gateway.get_user_info(access_token:)
    end
  end
end
