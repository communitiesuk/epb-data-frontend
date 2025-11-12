module Controller
  class GuidanceController < Controller::BaseController
    get "/guidance" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :guidance
    end

    get "/guidance/data-dictionary" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/data_dictionary'
    end

    get "/guidance/linking-certificates-to-recommendations" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/linking_certificates_to_recommendations'
    end

    get "/guidance/how-the-data-is-produced" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/how_the_data_is_produced'
    end

    get "/guidance/changes-to-the-format-and-methodology" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/changes_to_the_format_and_methodology'
    end

    get "/guidance/licensing-restrictions" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/licensing_restrictions'
    end

    get "/guidance/data-protection-requirements" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/data_protection_requirements'
    end

    get "/guidance/data-limitations" do
      status 200
      @back_link_href = request.referer || "/"
      @hide_guidance_text = true
      erb :'guidance_pages/data_limitations'
    end

    get "/guidance/energy-certificate-data-apis" do
      status 200
      @back_link_href = request.referer || "/"

      params["referer"] = "guidance/energy-certificate-data-apis"

      erb :'guidance_pages/energy_certificate_data_apis', locals: { use_case: @container.get_object(:get_user_token_use_case) }
    rescue StandardError => e
      logger.error "Unexpected error during /guidance/energy-certificate-data-apis get endpoint: #{e.message}"
      server_error(e)
    end
  end
end
