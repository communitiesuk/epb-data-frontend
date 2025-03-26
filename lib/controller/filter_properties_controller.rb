module Controller
  class FilterPropertiesController < Controller::BaseController
    filter_properties =
      lambda do
        @errors = {}
        @error_form_ids = []
        @back_link_href = request.referer || "/"
        params["ratings"] ||= %w[A B C D E F G] unless request.post?
        status 200

        if request.post?
          validate_date
          validate_postcode
          validate_ratings if params["property_type"] == "domestic"
        end

        if request.post? && @errors.empty?
          erb :start_page
        else
          erb :filter_properties
        end
      end

    get "/filter-properties",
        &filter_properties

    post "/filter-properties",
         &filter_properties

  private

    def validate_date
      return if ViewModels::FilterProperties.is_valid_date(params)

      status 400
      @error_form_ids << "date-section"
      @errors[:date] = t("error.invalid_filter_option.date_invalid")
    end

    def validate_postcode
      return unless params["area-type"] == "postcode"

      begin
        Helper::PostcodeValidator.validate(params.fetch("postcode", ""))
      rescue Errors::PostcodeIncomplete
        status 400
        @error_form_ids << "area-type-section"
        @errors[:postcode] = t("error.invalid_filter_option.postcode_incomplete")
      rescue Errors::PostcodeWrongFormat
        status 400
        @error_form_ids << "area-type-section"
        @errors[:postcode] = t("error.invalid_filter_option.postcode_wrong_format")
      rescue Errors::PostcodeNotValid
        status 400
        @error_form_ids << "area-type-section"
        @errors[:postcode] = t("error.invalid_filter_option.postcode_invalid")
      end
    end

    def validate_ratings
      return unless params["ratings"].nil? || params["ratings"].empty?

      status 400
      @error_form_ids << "eff-rating-section"
      @errors[:eff_rating] = t("error.invalid_filter_option.eff_rating_invalid")
    end
  end
end
