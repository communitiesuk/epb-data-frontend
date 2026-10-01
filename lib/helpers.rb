# frozen_string_literal: true

require "net/http"
require "epb-auth-tools"
require "uri"
require "ostruct"

module Helpers
  def setup_locales
    I18n.load_path = Dir[File.join(settings.root, "/../../locales", "*.yml")]
    I18n.enforce_available_locales = true
    I18n.available_locales = %w[en cy]
  end

  def set_locale
    I18n.locale =
      if I18n.locale_available?(params["lang"])
        params["lang"]
      else
        I18n.default_locale
      end
  end

  def t(...)
    I18n.t(...)
  end

  def h(str)
    CGI.h str
  end

  def script_nonce
    ENV["SCRIPT_NONCE"]
  end

  def localised_url(url)
    if I18n.locale != I18n.available_locales[0]
      url += (url.include?("?") ? "&" : "?")
      url += "lang=#{I18n.locale}"
    end

    url
  end

  def assets_path(path)
    Helper::Assets.path path
  end

  def inline_svg(path, attrs = {})
    Helper::Assets.inline_svg(path, attrs)
  end

  def data_uri_svg(path)
    Helper::Assets.data_uri_svg path
  end

  def get_gov_header
    t("service_name")
  end

  def google_property
    ENV["GTM_PROPERTY_FINDING"]
  end

  def root_page_url
    localised_url "/"
  end

  def cookie_consent?
    request.cookies["cookie_consent"].nil? || request.cookies["cookie_consent"] == "true"
  end
end
