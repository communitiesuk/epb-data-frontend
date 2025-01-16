# frozen_string_literal: true

require "net/http"
require "epb-auth-tools"
require "uri"
require "ostruct"

module Helpers
  def get_subdomain_host(subdomain)
    current_url = request.url

    return "http://#{subdomain}.local.gov.uk:9393" if settings.development?

    if current_url.include?("integration")
      "https://#{subdomain}-integration.digital.communities.gov.uk"
    elsif current_url.include?("staging")
      "https://#{subdomain}-staging.digital.communities.gov.uk"
    else
      "https://#{subdomain}.service.gov.uk"
    end
  end

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

  def party_disclosure(
    code,
    string,
    code_prefix = "disclosure_code",
    _certificate_prefix = "domestic_epc"
  )
    translation_errored = false
    begin
      text = t(code_prefix + ".#{code}.relation", raise: true)
    rescue I18n::MissingTranslationData
      translation_errored = true
    end
    if translation_errored
      text = string
      if text.nil? || text.strip.empty?
        text =
          if code
            t("data_missing.disclosure_number_not_valid")
          else
            t("data_missing.no_disclosure")
          end
      end
    end

    text
  end

  def localised_url(url)
    if I18n.locale != I18n.available_locales[0]
      url += (url.include?("?") ? "&" : "?")
      url += "lang=#{I18n.locale}"
    end

    url
  end

  def filter_query_params(url, *filtered_params)
    begin
      uri = URI.parse url
    rescue URI::InvalidURIError
      return url.split("?").first # chances are it isn't important to retain query params that we aren't choosing to filter out
    end
    filtered_query_params = if uri.query
                              uri.query.split("&").each_with_object({}) do |pair, hash|
                                key, val = pair.split("=")
                                hash[key.to_sym] = val unless filtered_params.include?(key.to_sym)
                              end
                            else
                              {}
                            end
    uri.query = filtered_query_params.empty? ? nil : URI.encode_www_form(filtered_query_params)
    uri.to_s
  end

  def assets_path(path)
    Helper::Assets.path path
  end

  def inline_svg(path)
    Helper::Assets.inline_svg path
  end

  def data_uri_svg(path)
    Helper::Assets.data_uri_svg path
  end

  def date(date)
    parsed_date =
      (date.is_a?(Date) ? date : Date.parse(date)).strftime "%-d %B %Y"

    if I18n.locale.to_s == "cy"
      WELSH_MONTHS.each do |english_month, welsh_month|
        parsed_date.gsub!(english_month, welsh_month)
      end
    end

    parsed_date
  end

  def first_word_downcase(word)
    letter_array = word.split(" ")
    letter_array[0] = letter_array[0].downcase
    letter_array.join(" ")
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

  def get_service_root_page_url
    root_url = static_start_page_for_service is_finding_service: false
    !root_url.nil? && !root_url.empty? ? root_url : localised_url("#{get_subdomain_host('getting-new-energy-certificate')}/")
  end

  # Use reCAPTCHA only if the appropriate environment variables are set
  # To disable reCAPTCHA remove these ENV variables from the deployed app
  def using_recaptcha?
    %w[EPB_RECAPTCHA_SITE_KEY EPB_RECAPTCHA_SITE_SECRET].all? { |key| ENV.key? key }
  end

  def recaptcha_pass?
    return true unless using_recaptcha?

    response_token = params["g-recaptcha-response"]
    return false if response_token.nil?

    begin
      recaptcha = Net::HTTP.post_form URI("https://www.google.com/recaptcha/api/siteverify"), {
        secret: ENV["EPB_RECAPTCHA_SITE_SECRET"],
        response: response_token,
      }
      JSON.parse(recaptcha.body)["success"]
    rescue StandardError
      false
    end
  end

  def recaptcha_site_key
    ENV["EPB_RECAPTCHA_SITE_KEY"].to_s
  end

  def bot_user_agent?
    suspected_bot_user_agents.include? request.user_agent
  end

  def should_show_recaptcha?
    using_recaptcha? && bot_user_agent?
  end

  def suspected_bot_user_agents
    JSON.parse(ENV["EPB_SUSPECTED_BOT_USER_AGENTS"])
  rescue StandardError
    []
  end

  def cookie_consent?
    request.cookies["cookie_consent"].nil? || request.cookies["cookie_consent"] == "true"
  end
end
