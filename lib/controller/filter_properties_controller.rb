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
          validate_area
          validate_postcode
          validate_ratings if params["property_type"] == "domestic"
        end

        if request.post? && @errors.empty?
          begin
            redirect "/download/all?property_type=#{params['property_type']}" if default_filters?

            count = get_download_size(params)
            email = get_email_from_session(session)

            params["download_count"] = count
            params["email"] = email if email

            send_download_request(email)
            form_data = Rack::Utils.build_nested_query(params)
            redirect "/request-received-confirmation?#{form_data}"
          rescue StandardError => e
            case e
            when Errors::FilteredDataNotFound
              status 400
              @errors[:data_not_found] = t("error.data_not_found")
              @error_form_ids << "filter-properties-header"
              erb :filter_properties
            when Errors::UserEmailNotVerified, Errors::AuthenticationError, Errors::NetworkError
              logger.warn "Authentication error: #{e.message}"
              redirect "/login"
            else
              logger.error "Unexpected error during filter_properties post: #{e.message}"
              server_error(e)
            end
          end
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
      count = params["download_count"].to_i
      email = params["email"]
      erb :request_received_confirmation, locals: { count:, email: }
    rescue StandardError => e
      server_error(e)
    end

    get "/download-started-confirmation" do
      status 200
      @back_link_href = "/filter-properties?property_type=#{params['property_type']}"
      erb :download_started_confirmation
    end

  private

    def get_download_size(params_data)
      use_case = @container.get_object(:get_download_size_use_case)
      date_start = ViewModels::FilterProperties.start_date_from_inputs(params_data["from-year"], params_data["from-month"]).to_s
      date_end = ViewModels::FilterProperties.end_date_from_inputs(params_data["to-year"], params_data["to-month"]).to_s

      council = if params_data["local-authority"] != ["Select all"] && params_data["area-type"] == "local-authority"
                  params_data[params_data["area-type"]]
                end

      constituency = if params_data["parliamentary-constituency"] != ["Select all"] && params_data["area-type"] == "parliamentary-constituency"
                       params_data[params_data["area-type"]]
                     end

      postcode = if params_data["area-type"] == "postcode"
                   params_data[params_data["area-type"]]
                 end

      eff_rating = params_data["ratings"]

      use_case_args = {
        postcode:,
        council:,
        constituency:,
        eff_rating:,
        date_start:,
        date_end:,
      }

      use_case.execute(**use_case_args)
    end

    def send_download_request(email_address)
      area_value = params[params["area-type"]]
      date_start = ViewModels::FilterProperties.start_date_from_inputs(params["from-year"], params["from-month"])
      date_end = ViewModels::FilterProperties.end_date_from_inputs(params["to-year"], params["to-month"])
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

    def default_filters?
      default_filters = {
        "from-month" => "January",
        "from-year" => "2012",
        "to-month" => ViewModels::FilterProperties.previous_month,
        "to-year" => ViewModels::FilterProperties.current_year,
        "postcode" => "",
        "local-authority" => ["Select all"],
        "parliamentary-constituency" => ["Select all"],
        "ratings" => %w[A B C D E F G],
      }

      default_filters.all? { |key, value| params[key] == value }
    end

    def validate_date
      return if ViewModels::FilterProperties.is_valid_date?(params)

      status 400
      @error_form_ids << "date-section"
      @errors[:date] = t("error.invalid_filter_option.date_invalid")
    end

    def validate_area
      params["local-authority"] ? params["local-authority"] : params["local-authority"] = ["Select all"]
      params["parliamentary-constituency"] ? params["parliamentary-constituency"] : params["parliamentary-constituency"] = ["Select all"]
    end

    def validate_postcode
      return unless params["area-type"] == "postcode"

      begin
        postcode_check = Helper::PostcodeValidator.validate(params.fetch("postcode", ""))
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
      else
        params["postcode"] = postcode_check
      end
    end

    def validate_ratings
      return unless params["ratings"].nil? || params["ratings"].empty?

      status 400
      @error_form_ids << "eff-rating-section"
      @errors[:eff_rating] = t("error.invalid_filter_option.eff_rating_invalid")
    end

    def get_email_from_session(session)
      if Helper::Toggles.enabled?("epb-frontend-data-restrict-user-access")
        Helper::Session.get_session_value(session, :email_address)
        raise Errors::AuthenticationError, "Failed to get user email from session" unless email
      else
        "placeholder@email.com"
      end
    end
  end
end
