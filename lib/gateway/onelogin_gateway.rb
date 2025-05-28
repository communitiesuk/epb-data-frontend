module Gateway
  class OneloginGateway
    def initialize
      @host_url = ENV["ONELOGIN_HOST_URL"]
      @token_endpoint = "#{@host_url}/token"
      @user_info_endpoint = "#{@host_url}/userinfo"
    end

    def exchange_code_for_token(code:, redirect_uri:, jwt_assertion:)
      token_url = URI(@token_endpoint)

      conn = Faraday.new(url: token_url) do |builder|
        builder.request :url_encoded
        builder.response :json
        builder.adapter Faraday.default_adapter
      end

      token_request_body = {
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri,
        client_assertion: jwt_assertion,
        client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
      }

      response = conn.post do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = token_request_body
      end

      unless response.status.between?(200, 299)
        if response.body["error"] == "invalid_grant"
          raise Errors::InvalidGrantError, "Invalid grant: #{response.body['error_description']}"
        end

        raise Errors::TokenExchangeError, "OneLogin token exchange failed: #{response.body['error']} - #{response.body['error_description']}"
      end

      response.body
    rescue Faraday::Error => e
      raise Errors::NetworkError, "Network error during token exchange: #{e.message}"
    end

    def get_user_email(access_token:)
      conn = Faraday.new(url: @user_info_endpoint) do |builder|
        builder.request :url_encoded
        builder.response :json
        builder.adapter Faraday.default_adapter
      end

      response = conn.get do |req|
        req.headers["Authorization"] = "Bearer #{access_token}"
      end

      unless response.status == 200
        raise Errors::AuthenticationError, "Failed to fetch user email: #{response.body['error']}. #{response.body['error_description']}"
      end

      unless response.body["email_verified"] == true
        raise Errors::UserEmailNotVerified, "Email not verified for user: #{response.body['email']}"
      end

      {
        email: response.body["email"],
        email_verified: response.body["email_verified"],
      }
    rescue Faraday::Error => e
      raise Errors::NetworkError, "Network error during user email fetch: #{e.message}"
    end
  end
end
