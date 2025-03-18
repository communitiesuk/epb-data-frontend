module Controller
  class FilterPropertiesController < Controller::BaseController
    filter_properties =
      lambda do
        @errors = {}
        status 200
        @back_link_href = request.referer || "/"

        if request.post?
          unless ViewModels::FilterProperties.is_valid_date(params)
            status 400
            @errors[:date] = t("filter_properties.validation_errors.invalid_date")
          end

          if params["ratings"].nil? || params["ratings"].empty?
            status 400
            @errors[:eff_rating] = t("filter_properties.validation_errors.invalid_eff_rating")
          end
        end
        erb :filter_properties
      end

    get "/filter-properties",
        &filter_properties

    post "/filter-properties",
         &filter_properties
  end
end
