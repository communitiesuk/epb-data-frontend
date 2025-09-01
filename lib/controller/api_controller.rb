module Controller
  class ApiController < Controller::BaseController
    get "/api/my-account" do
      status 200
      @back_link_href = request.referer || "/"

      erb :my_account, locals: { use_case: @container.get_object(:get_user_token_use_case) }
    rescue StandardError => e
      case e
      when Errors::BearerTokenMissing
        logger.warn "Bearer token missing: #{e.message}"
        redirect "/login?referer=api/my-account"
      else
        logger.error "Unexpected error during /api/my-account get endpoint: #{e.message}"
        server_error(e)
      end
    end

    get "/api/api-guidance" do
      status 200
      @back_link_href = request.referer || "/"

      erb :api_guidance
    rescue StandardError => e
      logger.error "Unexpected error during /api/my-account get endpoint: #{e.message}"
      server_error(e)
    end
  end
end
