module Controller
  class FilterPropertiesController < Controller::BaseController
    filter_properties =
      lambda do
        @errors = {}
        @error_form_ids = []
        @back_link_href = "/type-of-properties"
        params["ratings"] ||= %w[A B C D E F G] unless request.post?
        status 200

        if request.post?
          validate_date
          validate_postcode
          validate_ratings if params["property_type"] == "domestic"
        end

        if request.post? && @errors.empty?
          send_download_request if ENV["STAGE"] != "test"
          form_data = Rack::Utils.build_nested_query(params)
          redirect "/request-received-confirmation?#{form_data}"
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
      @back_link_href = "/filter-properties?property_type=#{params['property_type']}"
      count = ENV["STAGE"] != "test" ? get_download_size(params) : 0
      erb :request_received_confirmation, locals: { count: }
    end

    get "/download-started-confirmation" do
      status 200
      @back_link_href = "/filter-properties?property_type=#{params['property_type']}"
      erb :download_started_confirmation
    end

  private

    def get_download_size(params_data)
      use_case = @container.get_object(:get_download_size_use_case)
      date_start = ViewModels::FilterProperties.dates_from_inputs(params_data["from-year"], params_data["from-month"]).to_s
      date_end = ViewModels::FilterProperties.dates_from_inputs(params_data["to-year"], params_data["to-month"]).to_s

      council = if params_data["local-authority"] == "Select all" || params_data["area-type"] != "local-authority"
                  nil
                else
                  [params_data[params_data["area-type"]]]
                end

      constituency = if params_data["parliamentary-constituency"] == "Select all" || params_data["area-type"] != "parliamentary-constituency"
                       nil
                     else
                       [params_data[params_data["area-type"]]]
                     end

      use_case_args = {
        postcode: params_data["area-type"] == "postcode" ? params_data[params_data["area-type"]] : nil,
        council:,
        constituency:,
        eff_rating: params_data["ratings"],
        date_start:,
        date_end:,
      }

      use_case.execute(**use_case_args)
    end

    def send_download_request
      area_value = params[params["area-type"]]
      date_start = ViewModels::FilterProperties.dates_from_inputs(params["from-year"], params["from-month"])
      date_end = ViewModels::FilterProperties.dates_from_inputs(params["to-year"], params["to-month"])
      email_address = ENV["NOTIFY_DATA_EMAIL_RECIPIENT"]
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
