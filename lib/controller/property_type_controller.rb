module Controller
  class PropertyTypeController < Controller::BaseController
    get "/type-of-properties" do
      status 200
      @errors = {}
      @back_link_href = "/data-access-options"
      erb :type_of_properties
    rescue StandardError => e
      case e
      when Errors::AuthenticationError
        logger.warn "Authentication error on type of properties controller: #{e.message}"
        send_to_sentry(e)
        message =
          e.methods.include?(:message) ? e.message : e

        error = { type: e.class.name, message: }

        error[:backtrace] = e.backtrace if e.methods.include? :backtrace

        @logger.error JSON.generate(error)
        redirect "/login"
      else
        server_error(e)
      end
    end

    post "/type-of-properties" do
      @errors = {}
      @error_form_ids = []
      if params["property_type"]
        redirect "/filter-properties?property_type=#{params['property_type']}"
      else
        @error_form_ids << "property-type-error"
        @errors[:property_type] = t("error.invalid_property_selection.heading")
        erb :type_of_properties
      end
    end
  end
end
