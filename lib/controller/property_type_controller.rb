module Controller
  class PropertyTypeController < Controller::BaseController
    get "/type-of-properties" do
      status 200
      @errors = {}
      @back_link_href = "/data-access-options"
      @page_title = page_title

      erb :type_of_properties
    rescue StandardError => e
      server_error(e)
    end

    post "/type-of-properties" do
      @errors = {}
      @error_form_ids = []
      if params["property_type"]
        redirect "/filter-properties?property_type=#{params['property_type']}"
      else
        @error_form_ids << "property-type-error"
        @errors[:property_type] = t("error.invalid_property_selection.heading")
        @page_title = "Error: #{page_title}"
        erb :type_of_properties
      end
    end

  private

    def page_title
      "#{t('property_type.title')} – #{t('layout.body.govuk')}"
    end
  end
end
