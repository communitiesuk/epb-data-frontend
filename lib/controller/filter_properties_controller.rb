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
          send_download_request if ENV["STAGE"] != "test"
          erb :request_received_confirmation
        else
          erb :filter_properties
        end
      end

    get "/filter-properties",
        &filter_properties

    post "/filter-properties",
         &filter_properties

    get "/request-received-confirmation" do
      status 200
      @back_link_href = request.referer || "/"
      erb :request_received_confirmation
    end

    get "/download-started-confirmation" do
      status 200
      @back_link_href = request.referer || "/"
      erb :download_started_confirmation
    end

  private

    def send_download_request
      area_value = params[params["area-type"]]
      date_start = ViewModels::FilterProperties.dates_from_inputs(params["from-year"], params["from-month"])
      date_end = ViewModels::FilterProperties.dates_from_inputs(params["to-year"], params["to-month"])
      email_address = ENV["TESTING_EMAIL_ADDRESS"]
      use_case_args = {
        property_type: params["property_type"],
        date_start:,
        date_end:,
        area_type: params["area-type"],
        area_value:,
        efficiency_ratings: params["ratings"] || nil,
        include_recommendations: params["recommendations"] || nil,
        email_address:,
      }
      use_case = @container.get_object(:send_download_request_use_case)
      use_case.execute(**use_case_args)
    end

    def validate_date
      return if ViewModels::FilterProperties.is_valid_date?(params)

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
