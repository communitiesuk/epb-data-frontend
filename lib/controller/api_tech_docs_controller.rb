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

    get "/api-technical-documentation/search-certificates" do
      set_headers
      @search_types = ViewModels::ApiTechDocs::SEARCH_TYPES
      @page_title = "#{t('api-technical-documentation.search_certificates.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/search_certificates'
    end

    # Old per-assessment-type search pages have been consolidated into a single page.
    get "/api-technical-documentation/search-certificates/:type" do
      redirect "/api-technical-documentation/search-certificates##{params['type']}", 301
    end

    get "/api-technical-documentation/search-certificates-changed" do
      set_headers
      @page_title = "#{t('api-technical-documentation.deltas.title')} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/deltas'
    end

    # Superseded by /search-certificates-changed, kept as a redirect for old links.
    get "/api-technical-documentation/deltas" do
      redirect "/api-technical-documentation/search-certificates-changed", 301
    end

    get "/api-technical-documentation/download/:title" do
      halt 404 unless ViewModels::ApiTechDocs::DOWNLOAD_TITLES.include?(params["title"])

      set_headers
      @title = params["title"]
      @title_label = ViewModels::ApiTechDocs.title_label(@title)
      @file_types = ViewModels::ApiTechDocs.download_file_types(@title)
      @page_title = "#{t('api-technical-documentation.download_files.title', assessment_type: @title_label)} – #{t('layout.body.govuk')}"

      erb :'api_tech_docs/download_files'
    end

    # Old per-file-type download and download-info pages have been consolidated into
    # a single page per asset type, with the file type shown as a section on that page.
    get "/api-technical-documentation/download/:title/:file_type" do
      canonical_title = ViewModels::ApiTechDocs.canonical_download_title(params["title"])

      redirect "/api-technical-documentation/download/#{canonical_title}##{params['file_type']}-download", 301
    end

    get "/api-technical-documentation/download-info/:title/:file_type" do
      canonical_title = ViewModels::ApiTechDocs.canonical_download_title(params["title"])

      redirect "/api-technical-documentation/download/#{canonical_title}##{params['file_type']}-info", 301
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
