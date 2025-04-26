module Controller
  class FileController < BaseController
    get "/download" do
      file_name = params["file"]
      s3_url = @container.get_object(:get_presigned_url_use_case).execute(file_name:)
      redirect s3_url
    rescue StandardError => e
      case e
      when Errors::FileNotFound
        status 404
        "#{t('error.error')}#{
          t('error.download_file.heading')
        } – #{t('error.download_file.file_not_found')} – #{
          t('layout.body.govuk')
        }"
      else
        server_error(e)
      end
    end
  end
end
