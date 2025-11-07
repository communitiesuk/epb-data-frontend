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

    get "/how-the-data-is-produced" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/how_the_data_is_produced'
    end

    get "/changes-to-the-format-and-methodology" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/changes_to_the_format_and_methodology'
    end

    get "/licensing-restrictions" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/licensing_restrictions'
    end

    get "/data-protection" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/data_protection'
    end
  end
end
