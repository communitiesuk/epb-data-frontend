# frozen_string_literal: true

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
    VALID_PROPERTY_TYPES = %w[domestic non-domestic display].freeze
    HOST_NAME = "get-energy-certificate-data"

    helpers Helpers
    helpers Sinatra::CustomLogger
    helpers Sinatra::Capture
    Helper::Assets.setup_cache_control(self)

    set :views, "lib/views"
    set :erb, escape_html: true
    set :public_folder, proc { File.join(root, "/../../public") }
    set :static_cache_control, [:public, { max_age: 60 * 60 * 24 * 7 }] if ENV["ASSETS_VERSION"]
    set :logger, Logger.new($stdout, level: Logger::DEBUG)
    set :dump_errors, false

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

    set(:api_authentication) do |_|
      condition do
        Helper::Session.is_user_authenticated?(session)
      rescue Errors::AuthenticationError
        referrer = request.fullpath.delete_prefix("/")
        encoded_referrer = CGI.escape(referrer)
        redirect "/login/authorize?referer=#{encoded_referrer}", request.post? ? 303 : 302
      end
    end

    set(:opt_out_authentication) do |_|
      condition do
        Helper::Session.is_user_authenticated?(session)
      rescue Errors::AuthenticationError
        redirect "/login?referer=opt-out", request.post? ? 303 : 302
      end
    end

    before do
      set_locale
      cache_control :no_store
      halt 503, erb(:service_unavailable) if request.path != "/healthcheck" && Helper::Toggles.enabled?("ebp-data-frontend-maintenance-mode")
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
      logger.error JSON.generate(error_details(exception))
      status 500
      erb :error_page_500
    end

  private

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
