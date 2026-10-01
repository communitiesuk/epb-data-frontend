# frozen_string_literal: true

require "rack/protection"

class FrontendService < Controller::BaseController
  configure do
    is_dev_or_test = %i[development test].include?(settings.environment)
    use Rack::Session::Cookie,
        key: "epb_data.session",
        secret: ENV["SESSION_SECRET"],
        expire_after: 60 * 60, # 1 hour
        secure: !is_dev_or_test,
        same_site: is_dev_or_test ? :lax : :none,
        httponly: true

    use Rack::Protection
    set :protection, except: [:path_traversal]
  end

  use Controller::HomeController

  unless ENV["APP_ENV"] == "test"
    use Rack::Protection::AuthenticityToken
  end
  use Rack::Protection::RemoteReferrer
  use Controller::CookieController
  use Controller::DataAccessController
  use Controller::PropertyTypeController
  use Controller::FilterPropertiesController
  use Controller::FileController
  use Controller::UserController
  use Controller::ApiController
  use Controller::GuidanceController
  use Controller::ApiTechDocsController
  use Controller::OptOutController
end
