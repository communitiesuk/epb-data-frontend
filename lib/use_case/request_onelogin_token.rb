module UseCase
  class RequestOneloginToken
    def initialize(onelogin_token_gateway:)
      @onelogin_token_gateway = onelogin_token_gateway
    end

    def execute(code:, redirect_uri:)
      client_id = ENV["ONELOGIN_CLIENT_ID"]
      one_login_host = ENV["ONELOGIN_HOST_URL"]
      jwt_assertion = generate_client_jwt_assertion(client_id, one_login_host)
      @onelogin_token_gateway.exchange_code_for_token(code:, redirect_uri:, jwt_assertion:)
    end

  private

    def generate_client_jwt_assertion(client_id, one_login_host)
      aud = "#{one_login_host}/token"
      jti = SecureRandom.hex(16)
      jwt_assertion_body = Helper::Onelogin.get_jwt_assertion_body(client_id, aud, jti)
      Helper::Onelogin.sign_jwt(jwt_assertion_body)
    end
  end
end
