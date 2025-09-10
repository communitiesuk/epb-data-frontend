module Controller
  class FileController < BaseController
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
  end
end
