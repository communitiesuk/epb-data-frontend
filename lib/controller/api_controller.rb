module Controller
  class ApiController < Controller::BaseController
    get "/api/my-account" do
      status 200
      @back_link_href = request.referer || "/"
      erb :my_account
    end
  end
end
