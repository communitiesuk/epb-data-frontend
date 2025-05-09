module Controller
  class UserController < BaseController
    get "/login" do
      status 200
      @back_link_href = "/type-of-properties"
      erb :login
    rescue StandardError => e
      server_error(e)
    end
  end
end
