module Controller
  class GuidanceController < Controller::BaseController
    get "/guidance" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :guidance
    end
  end
end
