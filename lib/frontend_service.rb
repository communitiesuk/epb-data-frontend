# frozen_string_literal: true

require "rack/protection"

class FrontendService < Controller::BaseController
  configure do
    is_development = settings.environment == :development

    use Rack::Session::Cookie,
        key: "epb_data.session",
        secret: ENV["SESSION_SECRET"],
        expire_after: 60 * 60, # 1 hour
        secure: !is_development,
        same_site: is_development ? :lax : :none,
        httponly: true

    use Rack::Protection
    set :protection, except: [:path_traversal]
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
    also_reload "lib/**/*.rb"
    set :host_authorization, { permitted_hosts: [] }
  end

  use Controller::HomeController

  if ENV["enable-csrf"]
    use Rack::Protection::AuthenticityToken
    use Rack::Protection::RemoteReferrer
  end
  use Controller::CookieController
  use Controller::PropertyTypeController
  use Controller::FilterPropertiesController
  use Controller::FileController
  use Controller::UserController
  use Controller::ApiController
  use Controller::GuidanceController
  use Controller::ApiTechDocsController

  use Controller::OptOutController
end
