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

    def self.sign_request(request)
      raise Errors::MissingEnvVariable, "ONELOGIN_TLS_KEYS" if ENV["ONELOGIN_TLS_KEYS"].nil? || ENV["ONELOGIN_TLS_KEYS"].empty?

      tls_keys = ENV["ONELOGIN_TLS_KEYS"]
      private_key = extract_private_key(tls_keys)
      kid = extract_kid(tls_keys)

      JWT.encode(request, private_key, "RS256", { kid: kid })
    rescue Errors::MissingEnvVariable
      raise
    rescue StandardError => e
      raise Errors::OneloginSigningError, "Failed to sign request: #{e.message}"
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
