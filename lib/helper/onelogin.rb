module Helper
  class Onelogin
    def self.get_authorize_request(client_id, aud, state, nonce, redirect_uri)
      {
        aud: aud,
        iss: client_id,
        response_type: "code",
        client_id: client_id,
        redirect_uri: redirect_uri,
        scope: "openid email",
        state: state,
        nonce: nonce,
        vtr: '["Cl.Cm"]',
        ui_locales: "en",
      }
    end

    def self.get_jwt_assertion_body(client_id, aud, jti)
      {
        aud: aud,
        iss: client_id,
        sub: client_id,
        exp: Time.now.to_i + (5 * 60),
        jti: jti,
        iat: Time.now.to_i,
      }
    end

    def self.sign_jwt(jwt_body)
      raise Errors::MissingEnvVariable, "ONELOGIN_TLS_KEYS" if ENV["ONELOGIN_TLS_KEYS"].nil? || ENV["ONELOGIN_TLS_KEYS"].empty?

      tls_keys = ENV["ONELOGIN_TLS_KEYS"]
      private_key = extract_private_key(tls_keys)
      kid = extract_kid(tls_keys)

      JWT.encode(jwt_body, private_key, "RS256", { kid: kid })
    rescue Errors::MissingEnvVariable
      raise
    rescue StandardError => e
      raise Errors::OneloginSigningError, "Failed to sign request: #{e.message}"
    end

    def self.validate_state_cookie(received_state, stored_state)
      if received_state != stored_state
        raise Errors::StateMismatch, "State mismatch. Expected #{stored_state}, got #{received_state}"
      end
    end

    def self.check_one_login_errors(params)
      if params[:error]
        case params[:error]
        when "access_denied"
          raise Errors::AccessDeniedError, "OneLogin callback: Access denied. Description: #{params[:error_description]}"
        when "login_required"
          raise Errors::LoginRequiredError, "OneLogin callback: Login required. Description: #{params[:error_description]}"
        else
          raise Errors::AuthenticationError, "OneLogin callback: Error received: #{params[:error]}. Description: #{params[:error_description]}"
        end
      end
    end

    def self.validate_user_token(request)
      user_token = request.cookies["user_token"]
      raise Errors::AuthenticationError, "Missing 'user_token' cookie" if user_token.nil?

      user_token = JSON.parse(user_token)
      access_token = user_token["access_token"]
      raise Errors::AuthenticationError, "Missing access_token in 'user_token' cookie" if access_token.nil?

      access_token
    rescue JSON::ParserError
      raise Errors::AuthenticationError, "Invalid 'user_token' cookie."
    end

    def self.fetch_user_email(request:, use_case:)
      if Helper::Toggles.enabled?("epb-frontend-data-restrict-user-access")
        access_token = validate_user_token request
        use_case.execute(access_token:)[:email]
      else
        # If the toggle is not enabled, return a placeholder email
        "placeholder@email.com"
      end
    end

    private_class_method def self.extract_private_key(tls_keys)
      onelogin_keys = JSON.parse(tls_keys)
      private_key_pem = onelogin_keys["private_key"]
      OpenSSL::PKey::RSA.new(private_key_pem)
    end

    private_class_method def self.extract_kid(tls_keys)
      onelogin_keys = JSON.parse(tls_keys)
      onelogin_keys["kid"]
    end
  end
end
