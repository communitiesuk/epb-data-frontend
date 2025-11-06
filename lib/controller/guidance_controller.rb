module Controller
  class GuidanceController < Controller::BaseController
    get "/guidance" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :guidance
    end

    get "/how-to-link-certificates-to-recommendations" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/link_certificates_to_recommendations'
    end
  end
end
