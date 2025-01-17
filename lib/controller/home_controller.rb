module Controller
  class HomeController < Controller::BaseController
    get "/healthcheck" do
      status 200
    end
  end
end
