# frozen_string_literal: true

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
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
    also_reload "lib/**/*.rb"
    set :host_authorization, { permitted_hosts: [] }
  end

  use Controller::HomeController
  use Controller::PropertyTypeController
  use Controller::FilterPropertiesController
  use Controller::FileController
  use Controller::UserController
  use Controller::ApiController
  use Controller::GuidanceController
  use Controller::ApiTechDocsController
  use Controller::OptOutController
end
