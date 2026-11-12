require "i18n"
require "i18n/backend/fallbacks"
require "sinatra/base"
require "sinatra/cookies"
require "sinatra/custom_logger"
require "sinatra/capture"
require_relative "../container"
require_relative "../helper/toggles"

module Controller
  class BaseController < Sinatra::Base
    RESTRICTED_PATHS = %w[
      /api/my-account
      /api/my-account/delete-account
      /api/my-account/toggle-email-notifications
      /download
      /download/all
      /filter-properties
      /opt-out/certificate-details
      /opt-out/check-your-answers
      /opt-out/name
      /opt-out/received
      /type-of-properties
    ].freeze
    VALID_PROPERTY_TYPES = %w[domestic non-domestic display].freeze
    HOST_NAME = "get-energy-certificate-data".freeze

    attr_reader :toggles

    helpers Helpers
    helpers Sinatra::CustomLogger
    helpers Sinatra::Capture

    set :views, "lib/views"
    set :erb, escape_html: true
    set :public_folder, proc { File.join(root, "/../../public") }
    set :static_cache_control, [:public, { max_age: 60 * 60 * 24 * 7 }] if ENV["ASSETS_VERSION"]
    set :logger, Logger.new($stdout, level: Logger::DEBUG)
    set :dump_errors, false

    Helper::Assets.setup_cache_control(self)

    configure :production do
      logger.level = Logger::WARN
    end

    configure :development do
      require "sinatra/reloader"
      register Sinatra::Reloader
      also_reload "lib/**/*.rb"
      set :host_authorization, { permitted_hosts: [] }
      set :show_exceptions, :after_handler
      set :dump_errors, true
    end

    configure :test do
      logger.level = Logger::FATAL
    end

    def initialize(*, container: nil, **)
      super(*)
      setup_locales
      @toggles = Helper::Toggles
      @container = container || Container.new
    end

    before do
      set_locale
      cache_control :no_store
      Helper::Session.is_user_authenticated?(session) if is_restricted?
      halt 503, erb(:service_unavailable) if request.path != "/healthcheck" && Helper::Toggles.enabled?("ebp-data-frontend-maintenance-mode")
    rescue Errors::AuthenticationError
      login_url = if request.path.start_with?("/opt-out")
                    "/login?referer=opt-out"
                  else
                    referrer = request.fullpath.delete_prefix("/")
                    encoded_referrer = CGI.escape(referrer)
                    "/login/authorize?referer=#{encoded_referrer}"
                  end
      redirect login_url, request.post? ? 303 : 302
    end

    get "/" do
      status 200
      @allow_indexing = true
      erb :start_page
    end

    not_found do
      status 404
      erb :error_page_404
    end

    error Errors::RequestTimeoutError do |exception|
      logger.error JSON.generate(error_details(exception))
      status 504
      erb :error_page_500
    end

    error do |exception|
      Sentry.capture_exception(exception) if defined?(Sentry)
      logger.error JSON.generate(error_details(exception))
      status 500
      erb :error_page_500
    end

  private

    def is_restricted?
      RESTRICTED_PATHS.include?(request.path) || false
    end

    def property_type_valid?(property_type)
      VALID_PROPERTY_TYPES.include?(property_type)
    end

    def error_details(exception)
      {
        type: exception.class.name,
        message: exception.message,
        backtrace: exception&.backtrace&.select { it.start_with?(File.expand_path("..", __dir__)) },
        cause: exception.cause && error_details(exception.cause),
      }.compact
    end
  end
end
