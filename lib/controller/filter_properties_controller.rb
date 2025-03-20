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
            @errors[:date] = t("error.invalid_filter_option.date_invalid")
          end

          if params["ratings"].nil? || params["ratings"].empty?
            status 400
            @errors[:eff_rating] = t("error.invalid_filter_option.eff_rating_invalid")
          end

          if params["area-type"] == "postcode"
            begin
              Helper::PostcodeValidator.validate(params.fetch("postcode", ""))
            rescue Errors::PostcodeIncomplete
              status 400
              @errors[:postcode] = t("error.invalid_filter_option.postcode_incomplete")
            rescue Errors::PostcodeWrongFormat
              status 400
              @errors[:postcode] = t("error.invalid_filter_option.postcode_wrong_format")
            rescue Errors::PostcodeNotValid
              status 400
              @errors[:postcode] = t("error.invalid_filter_option.postcode_invalid")
            end
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
