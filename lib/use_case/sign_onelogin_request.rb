module UseCase
  class SignOneloginRequest
    def execute(client_id:, aud:, state:, nonce:, redirect_uri:)
      request = Helper::Onelogin.get_authorize_request(client_id, aud, state, nonce, redirect_uri)
      Helper::Onelogin.sign_jwt(request)
    end
  end
end
