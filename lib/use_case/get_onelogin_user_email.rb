module UseCase
  class GetOneloginUserEmail
    def initialize(onelogin_gateway:)
      @onelogin_gateway = onelogin_gateway
    end

    def execute(access_token:)
      @onelogin_gateway.get_user_email(access_token:)
    end
  end
end
