module Controller
  class UserController < BaseController
    get "/login" do
      status 200
      @back_link_href = "/data-access-options"
      erb :login
    rescue StandardError => e
      server_error(e)
    end

    get "/login/authorize" do
      client_id = ENV["ONELOGIN_CLIENT_ID"]
      host_url = ENV["ONELOGIN_HOST_URL"]
      frontend_url = "#{request.scheme}://#{request.host_with_port}"
      aud = "#{host_url}/authorize"
      redirect_uri = "#{frontend_url}/login/callback"

      nonce = request.cookies["nonce"] || SecureRandom.hex(16)
      state = request.cookies["state"] || SecureRandom.hex(16)

      response.set_cookie("nonce", value: nonce, path: "/login", expires: Time.now + 3600)
      response.set_cookie("state", value: state, path: "/login", expires: Time.now + 3600)

      use_case = @container.get_object(:sign_onelogin_request_use_case)

      use_case_args = {
        aud:,
        client_id:,
        redirect_uri:,
        state:,
        nonce:,
      }

      signed_request = use_case.execute(**use_case_args)

      query_string = URI.encode_www_form({
        client_id: client_id,
        scope: "openid email",
        response_type: "code",
        request: signed_request,
      })
      redirect "#{host_url}/authorize?#{query_string}"
    end

    get "/login/callback" do
      validate_one_login_callback
      token_response_hash = exchange_code_for_token

      expires_in = token_response_hash["expires_in"].to_i
      expiration_time = Time.now + expires_in

      response.set_cookie(:logged_in, {
        value: token_response_hash,
        expires: expiration_time,
        path: "/",
      })

      redirect "/type-of-properties"
    rescue StandardError => e
      case e
      when Errors::StateMismatch, Errors::AccessDeniedError, Errors::LoginRequiredError, Errors::InvalidGrantError
        redirect "/login"
        logger.warn e.message
      when Errors::TokenExchangeError, Errors::AuthenticationError, Errors::NetworkError
        logger.warn "Authentication error: #{e.message}"
        server_error(e)
      else
        logger.error "Unexpected error during login callback: #{e.message}"
        server_error(e)
      end
    end

    get "/jwks" do
      status 200
      response.content_type = "application/json"
      onelogin_keys = JSON.parse(ENV["ONELOGIN_TLS_KEYS"])
      public_key_pem = onelogin_keys["public_key"]
      public_key = OpenSSL::PKey::RSA.new(public_key_pem)

      jwk = JWT::JWK.new(public_key)
      jwks_hash = jwk.export
      jwks_hash[:kid] = onelogin_keys["kid"]
      jwks_hash[:use] = "sig"

      { keys: [jwks_hash] }.to_json
    rescue StandardError => e
      server_error(e)
    end

    def validate_one_login_callback
      received_state = params[:state]
      stored_state = request.cookies["state"]

      Helper::Onelogin.validate_state_cookie(received_state, stored_state)
      Helper::Onelogin.check_one_login_errors(params)

      response.delete_cookie("state", path: request.path)
      response.delete_cookie("nonce", path: request.path)
    end

    def exchange_code_for_token
      frontend_url = "#{request.scheme}://#{request.host_with_port}"
      redirect_uri = "#{frontend_url}/login/callback"
      authorisation_code = params[:code]

      use_case_args = {
        code: authorisation_code,
        redirect_uri: redirect_uri,
      }
      use_case = @container.get_object(:request_onelogin_token_use_case)
      use_case.execute(**use_case_args)
    end
  end
end
