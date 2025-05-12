module Controller
  class UserController < BaseController
    get "/login" do
      status 200
      @back_link_href = "/data-access-options"
      erb :login
    rescue StandardError => e
      server_error(e)
    end
  end
end
