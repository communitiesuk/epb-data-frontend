module Controller
  class ApiTechDocsController < Controller::BaseController
    get "/api-technical-documentation" do
      status 200
      erb :'api_tech_docs/overview'
    end

    get "/api-technical-documentation/making-a-request" do
      status 200
      erb :'api_tech_docs/making_request'
    end

    get "/api-technical-documentation/headers" do
      set_headers
      erb :'api_tech_docs/headers'
    end

    get "/api-technical-documentation/fetch-certificate-data" do
      set_headers
      erb :'api_tech_docs/fetch_certificate_data'
    end

  private

    def set_headers
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      @main_no_padding = true
    end
  end
end
