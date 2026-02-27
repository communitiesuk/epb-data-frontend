module Controller
  class ApiTechDocsController < Controller::BaseController
    get "/api-technical-documentation" do
      set_headers
      @page_title = "#{t('api-technical-documentation.overview.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/overview'
    end

    get "/api-technical-documentation/making-a-request" do
      set_headers
      @page_title = "#{t('api-technical-documentation.making_a_request.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/making_request'
    end

    get "/api-technical-documentation/fetch-certificate-data" do
      set_headers
      @page_title = "#{t('api-technical-documentation.fetch_certificate_data.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/fetch_certificate_data'
    end

    get "/api-technical-documentation/search-certificates-changed" do
      set_headers
      @page_title = "#{t('api-technical-documentation.deltas.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/deltas'
    end

    get "/api-technical-documentation/search-certificates/:type" do
      set_headers
      @assessment_type_title = params["type"].gsub("-", " ")
      @assessment_type = params["type"]
      @page_title = "#{t('api-technical-documentation.search_certificates.title', assessment_type: @assessment_type_title)} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/search_certificates'
    end

    get "/api-technical-documentation/download/:title/:file_type" do
      set_headers
      @assessment_type_title = params["title"]
      @assessment_type = params["title"]
      @file_type = params["file_type"]
      @page_title = "#{t('api-technical-documentation.download_file.title', assessment_type: @assessment_type_title, file_type: @file_type)} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/download_file'
    end

    get "/api-technical-documentation/download-info/:title/:file_type" do
      set_headers
      @assessment_type_title = params["title"]
      @assessment_type = params["title"]
      @file_type = params["file_type"]
      @page_title = "#{t('api-technical-documentation.download_info.title', assessment_type: @assessment_type_title, file_type: @file_type)} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/file_info'
    end

    get "/api-technical-documentation/codes" do
      set_headers
      @page_title = "#{t('api-technical-documentation.fetch_epc_codes.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/codes'
    end

    get "/api-technical-documentation/codes-info" do
      set_headers
      @page_title = "#{t('api-technical-documentation.fetch_epc_codes_information.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/codes_info'
    end

  private

    def set_headers
      status 200
      @hide_guidance_text = true
      @main_no_padding = true
    end
  end
end
