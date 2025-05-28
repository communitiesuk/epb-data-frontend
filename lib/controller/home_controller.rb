module Controller
  class HomeController < Controller::BaseController
    get "/healthcheck" do
      status 200
    end

    get "/data-access-options" do
      status 200
      @page_title = t("data_access_options.title")
      @back_link_href = "/"
      erb :data_access_options
    end

    get "/data-access-options/login" do
      if Helper::Toggles.enabled?("epb-frontend-data-restrict-user-access")
        redirect "/login"
      else
        redirect "/type-of-properties"
      end
    end

    get "/guidance" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :guidance
    end

    get "/cookies" do
      @page_title = "#{t('cookies.title')} – #{t('layout.body.govuk')}"
      status 200
      erb :cookies, locals: { is_success: params[:success] == "true" }
    end

    post "/cookies" do
      cookie_value = params[:cookies_setting] == "false" ? "false" : "true"
      response.set_cookie("cookie_consent", { value: cookie_value, path: "/", same_site: :strict })

      redirect localised_url("/cookies?success=true")
    end

    get "/api-healthcheck" do
      uri = URI("#{ENV['EPB_DATA_WAREHOUSE_API_URL']}/healthcheck")
      response = Net::HTTP.get_response(uri)

      status response.code.to_i
      {
        status: response.code.to_i,
        message: "Connection to API: OK",
      }.to_json
    rescue StandardError => e
      status 500
      {
        status: 500,
        error: "Failed to reach API",
        details: e.message,
      }.to_json
    end
  end
end
