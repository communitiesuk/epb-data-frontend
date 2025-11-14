module Controller
  class ApiTechDocsController < Controller::BaseController
    get "/api-technical-documentation" do
      status 200
      status 200
      @back_link_href = request.referer || "/"
      @no_main_wrapper = true
      erb :api_technical_documentation
    end
  end
end
