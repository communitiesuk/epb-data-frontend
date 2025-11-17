module Controller
  class ApiTechDocsController < Controller::BaseController
    get "/api-technical-documentation" do
      status 200
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      @main_no_padding = true
      erb :'api_tech_docs/overview'
    end
  end
end
