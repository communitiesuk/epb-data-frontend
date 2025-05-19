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
      redirect_uri = "#{frontend_url}/user/authorise"

      nonce = request.cookies["nonce"] || SecureRandom.hex(16)
      state = request.cookies["state"] || SecureRandom.hex(16)

      response.set_cookie("nonce", value: nonce, path: request.path, expires: Time.now + 3600)
      response.set_cookie("state", value: state, path: request.path, expires: Time.now + 3600)

      use_case = @container.get_object(:sign_onelogin_request_use_case)

      use_case_args = {
        aud:,
        client_id:,
        redirect_uri:,
        state:,
        nonce:,
      }

      signed_request = use_case.execute(**use_case_args)

      query_string = "authorize?response_type=code"\
        "&scope=openid email"\
        "&client_id=#{client_id}" \
        "&request=#{URI.encode_www_form_component(signed_request)}"

      redirect "#{host_url}/#{query_string}"
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

      jwks_hash.to_json
    rescue StandardError => e
      server_error(e)
    end
  end
end
