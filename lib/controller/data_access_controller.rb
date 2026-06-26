module Controller
  class DataAccessController < Controller::BaseController
    get "/data-access-options" do
      @errors = {}
      @back_link_href = "/"
      @page_title = "#{t('data_access_options.title')} – #{t('layout.body.govuk')}"

      erb :data_access_options
    end

    post "/data-access-options" do
      @errors = {}
      @error_form_ids = []
      case params["access_type"]
      when "download"
        redirect "/login/authorize?referer=type-of-properties"
      when "api"
        redirect "/guidance/energy-certificate-data-apis"
      else
        @error_form_ids << "data_access_options-error"
        @errors[:data_access_options] = t("error.invalid_data_access_selection.heading")
        erb :data_access_options
      end
    end
  end
end
