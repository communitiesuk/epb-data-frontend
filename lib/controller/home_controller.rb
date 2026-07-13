module Controller
  class HomeController < Controller::BaseController
    get "/healthcheck" do
      status 200
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

    get "/accessibility-statement" do
      status 200
      @page_title = "#{t('accessibility_statement.top_heading')} – #{t('layout.body.govuk')}"
      @back_link_href = "/"

      erb :accessibility_statement
    end
  end
end
