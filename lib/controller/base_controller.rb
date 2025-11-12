require "erubis"
require "i18n"
require "i18n/backend/fallbacks"
require "sinatra/base"
require "sinatra/cookies"
require_relative "../container"
require_relative "../helper/toggles"

module Controller
  class BaseController < Sinatra::Base
    helpers Helpers
    attr_reader :toggles

    set :views, "lib/views"
    set :erb, escape_html: true
    set :public_folder, proc { File.join(root, "/../../public") }
    set :static_cache_control, [:public, { max_age: 60 * 60 * 24 * 7 }] if ENV["ASSETS_VERSION"]

    if ENV["STAGE"] == "test"
      require "capybara-lockstep"
      include Capybara::Lockstep::Helper
      set :show_exceptions, :after_handler
    end

    get "/" do
      status 200
      erb :start_page
    end

    def initialize(*args, container: nil)
      super
      setup_locales
      @toggles = Helper::Toggles
      @container = container || Container.new
      @logger = Logger.new($stdout)
      @logger.level = Logger::WARN
    end

    HOST_NAME = "get-energy-certificate-data".freeze
    Helper::Assets.setup_cache_control(self)

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

    before do
      set_locale
      Helper::Session.set_local(session)
      if is_restricted?
        Helper::Session.is_user_authenticated?(session)
      end
      raise MaintenanceMode if request.path != "/healthcheck" && Helper::Toggles.enabled?("ebp-data-frontend-maintenance-mode")
    rescue Errors::AuthenticationError
      redirect_url = "/login"

      referer_path = case request.path
                     when "/api/my-account"
                       "api/my-account"
                     when "/guidance/energy-certificate-data-apis"
                       "guidance/energy-certificate-data-apis"
                     end

      redirect_url += "?referer=#{referer_path}" if referer_path

      redirect redirect_url
    end

    def show(template, locals, layout = :layout)
      locals[:errors] = @errors
      erb template, layout:, locals:
    end

    not_found do
      @page_title = "#{t('error.404.heading')} – #{t('layout.body.govuk')}"
      status 404
      erb :error_page_404 unless @errors
    end

    class MaintenanceMode < RuntimeError
      include Errors::DoNotReport
    end

    error MaintenanceMode do
      status 503
      @page_title =
        "#{t('service_unavailable.title')} – #{t('layout.body.govuk')}"
      erb :service_unavailable
    end

    def send_to_sentry(exception)
      was_timeout = exception.is_a?(Errors::RequestTimeoutError)
      Sentry.capture_exception(exception) if defined?(Sentry) && !was_timeout
    end

    def server_error(exception)
      was_timeout = exception.is_a?(Errors::RequestTimeoutError)
      Sentry.capture_exception(exception) if defined?(Sentry) && !was_timeout

      message =
        exception.methods.include?(:message) ? exception.message : exception

      error = { type: exception.class.name, message: }

      error[:backtrace] = exception.backtrace if exception.methods.include? :backtrace

      @logger.error JSON.generate(error)
      @page_title =
        "#{t('error.500.heading')} – #{t('layout.body.govuk')}"
      status(was_timeout ? 504 : 500)
      erb :error_page_500
    end

    def is_restricted?
      restricted_paths = %w[/type-of-properties /api/my-account /filter-properties /download /download/all]
      return false unless ENV["LOCAL_SESSION"].nil?

      restricted_paths.include?(request.path) ? true : false
    end
  end
end
