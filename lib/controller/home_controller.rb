module Controller
  class HomeController < Controller::BaseController

    get "/healthcheck" do
      status 200
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
  end
end