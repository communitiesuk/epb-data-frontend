module Controller
  class FileController < BaseController
    include Helper::DataDictionary

    get "/download" do
      file_name = params["file"]
      s3_url = @container.get_object(:get_presigned_url_use_case).execute(file_name:)
      redirect s3_url
    rescue StandardError => e
      case e
      when Errors::FileNotFound
        @page_title = "#{t('error.error')}#{
          t('error.download_file.heading')
        } – #{t('error.download_file.file_not_found')} – #{
          t('layout.body.govuk')
        }"
        status 404
      else
        server_error(e)
      end
    end

    get "/download/all" do
      property_type = params["property_type"]
      s3_url = @container.get_object(:get_presigned_url_use_case).execute(file_name: "full-load/#{property_type}-csv.zip")
      redirect s3_url
    rescue StandardError => e
      case e
      when Errors::FileNotFound
        @page_title = "#{t('error.error')}#{
          t('error.download_file.heading')
        } – #{t('error.download_file.file_not_found')} – #{
          t('layout.body.govuk')
        }"
        status 404
      else
        server_error(e)
      end
    end

    get "/download/codes" do
      s3_url = @container.get_object(:get_presigned_url_use_case).execute(file_name: "codes.csv")
      redirect s3_url
    rescue StandardError => e
      case e
      when Errors::FileNotFound
        @page_title = "#{t('error.error')}#{
          t('error.download_file.heading')
        } – #{t('error.download_file.file_not_found')} – #{
          t('layout.body.govuk')
        }"
        status 404
      else
        server_error(e)
      end
    end

    get "/download/data-dictionary" do
      property_type = params["property_type"]
      raise Errors::InvalidPropertyType unless %w[domestic non_domestic display].include? property_type

      download_data_dictionary_csv(property_type: property_type)
    rescue StandardError => e
      case e
      when Errors::FileNotFound
        @page_title = "#{t('error.error')}#{
                  t('error.download_file.heading')
                } – #{t('error.download_file.file_not_found')} – #{
                  t('layout.body.govuk')
                }"
        status 404
      when Errors::InvalidPropertyType
        @page_title = "#{t('error.error')}#{
          t('error.download_file.heading')
        } – #{t('error.download_file.invalid_property_type')} – #{
          t('layout.body.govuk')
        }"
        status 404
      else
        server_error(e)
      end
    end
  end
end
