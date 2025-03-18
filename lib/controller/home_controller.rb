module Controller
  class HomeController < Controller::BaseController
    get "/healthcheck" do
      status 200
    end

    get "/data_access_options" do
      status 200
      @page_title = t("data_access_options.title")
      @back_link_href = "/"
      erb :data_access_options
    end

    get "/guidance" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :guidance
    end
  end
end
