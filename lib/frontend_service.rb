# frozen_string_literal: true

class FrontendService < Controller::BaseController
  use Controller::HomeController
  use Controller::PropertyTypeController
  use Controller::FilterPropertiesController
  use Controller::FileController
  use Controller::UserController
  use Controller::ApiController
end
