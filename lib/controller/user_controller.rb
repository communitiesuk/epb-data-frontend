module Controller
  class UserController < BaseController
    get "/login" do
      status 200

      if params["referer"] == "/opt-out"
        if Helper::Session.get_session_value(session, :opt_out).values.first == "no"
          redirect localised_url("/opt-out/ineligible")
        end
      else
        @back_link_href = request.referer || "/"
      end

      authorize_url = case params["referer"]
                      when "api/my-account"
                        "/login/authorize?referer=api/my-account"
                      when "/opt-out"
                        "/login/authorize?referer=/opt-out"
                      else
                        "/login/authorize"
                      end

      erb :login, locals: { authorize_url: }
    rescue StandardError => e
      server_error(e)
    end

    get "/login/authorize" do
      client_id = ENV["ONELOGIN_CLIENT_ID"]
      host_url = ENV["ONELOGIN_HOST_URL"]
      frontend_url = "#{request.scheme}://#{request.host_with_port}"
      aud = "#{host_url}/authorize"
      redirect_uri = "#{frontend_url}/login/callback"

      case params["referer"]
      when "api/my-account"
        redirect_uri += "/admin"
      when "/opt-out"
        redirect_uri += "/opt-out"
      end

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
      one_login_callback(redirect_path: "type-of-properties")
    end

    get "/login/callback/admin" do
      one_login_callback(redirect_path: "api/my-account")
    end

    get "/login/callback/opt-out" do
      one_login_callback(redirect_path: "opt-out/name")
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

    get "/signed-out" do
      status 200
      erb :signed_out
    end

    get "/sign-out" do
      host_url = "#{ENV['ONELOGIN_HOST_URL']}/logout"
      frontend_url = "#{request.scheme}://#{request.host_with_port}"
      redirect_uri = "#{frontend_url}/signed-out"

      query_string = URI.encode_www_form({
        id_token_hint: Helper::Session.get_session_value(session, :id_token),
        post_logout_redirect_uri: redirect_uri,
      })
      Helper::Session.clear_session(session)
      redirect "#{host_url}?#{query_string}"
    end

    def validate_one_login_callback
      received_state = params[:state]
      stored_state = request.cookies["state"]

      Helper::Onelogin.validate_state_cookie(received_state, stored_state)
      Helper::Onelogin.check_one_login_errors(params)

      response.delete_cookie("state", path: request.path)
      response.delete_cookie("nonce", path: request.path)
    end

    def exchange_code_for_token(callback_path:)
      frontend_url = "#{request.scheme}://#{request.host_with_port}"
      redirect_uri = "#{frontend_url}#{callback_path}"

      authorisation_code = params[:code]

      use_case_args = {
        code: authorisation_code,
        redirect_uri: redirect_uri,
      }
      use_case = @container.get_object(:request_onelogin_token_use_case)
      use_case.execute(**use_case_args)
    end

    def one_login_callback(redirect_path:)
      validate_one_login_callback
      token_response_hash = exchange_code_for_token(callback_path: request.path)
      Helper::Onelogin.set_user_one_login_info(container: @container, session:, token_response_hash:)
      redirect "/#{redirect_path}?nocache=#{Time.now.to_i}"
    rescue StandardError => e
      case e
      when Errors::StateMismatch, Errors::AccessDeniedError, Errors::LoginRequiredError, Errors::InvalidGrantError
        message =
          e.methods.include?(:message) ? e.message : e

        error = { type: e.class.name, message: }

        error[:backtrace] = e.backtrace if e.methods.include? :backtrace

        @logger.error JSON.generate(error)

        redirect_link =  case redirect_path
                         when "api/my-account"
                           "/login?referer=api/my-account"
                         when "opt-out/name"
                           "/login?referer=/opt-out"
                         else
                           "/login"
                         end

        redirect localised_url(redirect_link)
      when Errors::TokenExchangeError, Errors::AuthenticationError, Errors::NetworkError
        @logger.warn "Authentication error: #{e.message}"
        server_error(e)
      else
        @logger.error "Unexpected error during login callback: #{e.message}"
        server_error(e)
      end
    end
  end
end
