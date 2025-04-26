# frozen_string_literal: true

class FrontendService < Controller::BaseController
  use Controller::HomeController
  use Controller::PropertyTypeController
  use Controller::FilterPropertiesController
  use Controller::FileController
end
