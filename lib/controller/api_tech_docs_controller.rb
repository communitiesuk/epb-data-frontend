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

    get "/api-technical-documentation/search-domestic-certificates" do
      set_headers
      @assessment_type_title = "domestic"
      @assessment_type = "domestic"
      erb :'api_tech_docs/search_certificates'
    end

    get "/api-technical-documentation/search-non-domestic-certificates" do
      set_headers
      @assessment_type_tile = "non domestic"
      @assessment_type = "non-domestic"
      erb :'api_tech_docs/search_certificates'
    end

  private

    def set_headers
      status 200
      @hide_guidance_text = true
      @main_no_padding = true
    end
  end
end
