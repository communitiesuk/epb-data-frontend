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

      nonce = request.cookies["nonce"] || SecureRandom.hex(16)
      response.set_cookie("nonce", value: nonce, path: request.path)

      query_string = "authorize?response_type=code"\
        "&scope=openid email"\
        "&client_id=#{client_id}" \
        "&state=STATE"\
        "&redirect_uri=#{frontend_url}/type-of-properties"\
        "&nonce=#{nonce}"\
        '&vtr=["Cl.CM.P2"]'\
        "&ui_locales=en"\
        "&claims=#{Rack::Utils.escape('{"userinfo":{"https://vocab.account.gov.uk/v1/coreIdentityJWT": null}}')}"\

      redirect "#{host_url}/#{query_string}"
    end
  end
end
