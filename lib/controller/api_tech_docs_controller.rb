module Controller
  class ApiTechDocsController < Controller::BaseController
    get "/api-technical-documentation" do
      set_headers
      erb :'api_tech_docs/overview'
    end

    get "/api-technical-documentation/making-a-request" do
      set_headers
      erb :'api_tech_docs/making_request'
    end

    get "/api-technical-documentation/fetch-certificate-data" do
      set_headers
      erb :'api_tech_docs/fetch_certificate_data'
    end

    get "/api-technical-documentation/search-certificates/:type" do
      set_headers
      @assessment_type_title = params["type"].gsub("-", " ")
      @assessment_type = params["title"]
      erb :'api_tech_docs/search_certificates'
    end

    get "/api-technical-documentation/download/:title/:file_type" do
      set_headers
      @assessment_type_title = params["title"]
      @assessment_type = params["title"]
      @file_type = params["file_type"]
      erb :'api_tech_docs/download_file'
    end

  private

    def set_headers
      status 200
      @hide_guidance_text = true
      @main_no_padding = true
    end
  end
end
