module Controller
  class HomeController < Controller::BaseController
    get "/", host_name: /#{HOST_NAME}/ do
      erb :home, layout: :layout
    end

    get "/healthcheck" do
      status 200
    end
  end
end