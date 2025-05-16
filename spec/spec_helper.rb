# frozen_string_literal: true

require "rspec"
require "rack/test"
require "webmock/rspec"
require "epb-auth-tools"
require "i18n"
require "helpers"
require "nokogiri"
require "compare-xml"
require "zeitwerk"
require "capybara/rspec"
require "active_support"
require "active_support/cache"
require "active_support/notifications"
require "rake"
require "timecop"
require "rack/session/cookie"

AUTH_URL = "http://test-auth-server.gov.uk"

ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = AUTH_URL
ENV["EPB_DATA_WAREHOUSE_API_URL"] = "http://epb-data-warehouse-api"
ENV["STAGE"] = "test"
ENV["EPB_UNLEASH_URI"] = "https://test-toggle-server/api"

ENV["AWS_ACCESS_KEY_ID"] = "test.aws.id"
ENV["AWS_SECRET_ACCESS_KEY"] = "test.aws.secret"
ENV["AWS_REGION"] = "eu-west-2"
ENV["NOTIFY_DATA_EMAIL_RECIPIENT"] = "epbtest@mctesty.com"
ENV["AWS_S3_USER_DATA_BUCKET_NAME"] = "user-data"
ENV["APP_ENV"] = "local"
ENV["SEND_DOWNLOAD_TOPIC_ARN"] = "arn:aws:sns:us-east-1:123456789012:testTopic"
ENV["ONELOGIN_HOST_URL"] = "https://oidc.integration.account.gov.uk"
ENV["ONELOGIN_CLIENT_ID"] = "test.onelogin.client.id"
ENV["ONELOGIN_TLS_KEYS"] = {
  kid: "355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb",
  public_key: "-----BEGIN PUBLIC KEY-----\n"\
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArGvxQU80uOxKzlmbCHNO\n"\
    "kjcgTF415lSHTmbr3x8jFEHvXu+NzXD0qHMIIQ217foYJAwT/RdTpaaeOW7sXdIq\n"\
    "gAUhQwCNhSyuTx0sIMM0G0YXHOmLXAiRzwApLBxKYYU4i66T6ACP7Io0pDEqHu0s\n"\
    "FrfdnfV+3JaaRlWkGXpKarwMtMAhzSdE5UGgxJ08d7qLJ/g8lbQZxcrVmyLragmY\n"\
    "HEfzgAYyv8WFKEj2n0rcFzntcjZXy9EZOxlFqMn27Vr/lz+Yye2zio4+j/d8S8Q6\n"\
    "V1oddVHwMAB8rG+CaTJg+63Z61dtStYMxIl2CFBld4UpWTkWrGdmHnKkYZeZRnrm\n"\
    "7QIDAQAB\n"\
    "-----END PUBLIC KEY-----",
  private_key: "-----BEGIN PRIVATE KEY-----\n" \
    "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCsa/FBTzS47ErO\n" \
    "WZsIc06SNyBMXjXmVIdOZuvfHyMUQe9e743NcPSocwghDbXt+hgkDBP9F1Olpp45\n" \
    "buxd0iqABSFDAI2FLK5PHSwgwzQbRhcc6YtcCJHPACksHEphhTiLrpPoAI/sijSk\n" \
    "MSoe7SwWt92d9X7clppGVaQZekpqvAy0wCHNJ0TlQaDEnTx3uosn+DyVtBnFytWb\n" \
    "IutqCZgcR/OABjK/xYUoSPafStwXOe1yNlfL0Rk7GUWoyfbtWv+XP5jJ7bOKjj6P\n" \
    "93xLxDpXWh11UfAwAHysb4JpMmD7rdnrV21K1gzEiXYIUGV3hSlZORasZ2YecqRh\n" \
    "l5lGeubtAgMBAAECggEADBcfmjBHJqZvEmwnGl8Xhdo2uhQrHGUV/dHqvUEOMSf0\n" \
    "dIhAvcSrazpxufufo7nTQofUSP1/QJDf7HASQ/vuPf7eF7gstEdvS53kj8GQYE84\n" \
    "ZK8dtgzlyIme2Xh8YL06O1U5Ct4rOW9xhIfsB7Ii0s7+y8pApJAs7jyoHp88I6LB\n" \
    "ldBKhb6XrLhyqpcyLfHsf1kIP9QDWn2qmsuOVUX9t9WSZZA3txQMBV3xOF0tKuXw\n" \
    "uWG1tj97L14433xa8HP1ljxFRuCth+77V5/kixvoxzxkwjZz01hWgZcTtffnJPbX\n" \
    "70R6AHOublv8My9KgX0ku83LbEK+f7PZn1I0NDX9YwKBgQDbFCiMyAjlmweYUQeq\n" \
    "ZK28iFIIngCFBD0ReZwp+xOur7AO+js+yamQiU5TeiuH98Aj5L2nWLFtF/K6+kyY\n" \
    "eueSKVReIoLy+7j2lKqQUymZdiWoyyJyKyoZV2uRrG+YYl+ntPd67MPNrLvAWUf8\n" \
    "aEHwKILFwlkV21mOodiIkRXTzwKBgQDJetRzZic77TezG1MgFzjm88rhY+WmuKO8\n" \
    "sj5NS2bUZ5doAryJi447dPNOl9QC7SOEyutpdDMBoKmwjPEMSlkFMPvUOp/YgW9Z\n" \
    "t+HfPfYiBwxKoNCmRzsO6aLa0HJkgFl7fQQLKTIInA5MXF1aOd6wNeQtiZcrnC5u\n" \
    "LH7VhmU8gwKBgQCMofYd2VMMwWYwuuNm2FZGzmOKsJK40K27CAvdTxWlb5ZfJvbd\n" \
    "KWs2I04qfCRxlfK7l9y/DkpnM5ZXvNFqmIsK4okMHK9e94QWlfyfxSLRJmyqXCvy\n" \
    "ig7uUZX133GLqqqo55xuRoqy/w1PPoDdYLfjSL4Z4NZ7F2H4E6ECmdAfNQKBgEEv\n" \
    "8JT1tDP7aE4WxSpY2RxAPJ/4BlGO48slkGrJvpdyfNY2LHIEKRyrlh0TmpDn0Noi\n" \
    "HVCdO/OG2+A3ebYUSAEZ/CCKZzVRi4lnqTjlf0E7LormxRtHaKBGj15kmt5ReKIv\n" \
    "rKM/zORkOWwTZlDO8HHqvczN+48slQkodFD5jr+pAoGAIsur/uBMqeedwjCMRQcD\n" \
    "9qvQg6QaWtBvuEkvP2winHbZLfZX/Yd1KJLr4lZqG1ZS1MdDoLN6RBF46t+F90B5\n" \
    "BmRZnic0hWcJiz5Rr9118wRxbblOleG11jEdkmGtLC8GB4LiQESukx58F/Wu6gj7\n" \
    "uXOI2l5UQWPY8/SfrLd4nEg=\n" \
    "-----END PRIVATE KEY-----",
}.to_json
I18n.load_path = Dir[File.join(File.dirname(__FILE__), "/../locales", "*.yml")]
I18n.enforce_available_locales = true
I18n.available_locales = %w[en cy]

# override the `t` helper so that it raises on missing translations when running tests
module Helpers
  def t(*args, **kwargs, &block)
    I18n.t(*args, raise: true, **kwargs, &block)
  end
end

class TestLoader
  def self.setup
    @loader = Zeitwerk::Loader.new
    @loader.push_dir("#{__dir__}/../lib/")
    @loader.push_dir("#{__dir__}/../spec/test_doubles/")
    @loader.setup
  end

  def self.override(path)
    load path
  end
end

TestLoader.setup

def loader_enable_override(name)
  TestLoader.override "overrides/#{name}.rb"
end

def loader_enable_original(lib_name)
  TestLoader.override "#{__dir__}/../lib/#{lib_name}.rb"
end

def get_task(name)
  rake = Rake::Application.new
  Rake.application = rake
  rake.load_rakefile
  rake.tasks.find { |task| task.to_s == name }
end

loader_enable_override "helper/toggles"

def save_response_to_file(file:, content:)
  File.write("#{file}.html", content)
end

module RSpecUnitMixin
  def get_api_client(api_url = nil)
    url = api_url.nil? ? ENV["EPB_DATA_WAREHOUSE_API_URL"] : api_url
    @get_api_client ||=
      Auth::HttpClient.new ENV["EPB_AUTH_CLIENT_ID"],
                           ENV["EPB_AUTH_CLIENT_SECRET"],
                           ENV["EPB_AUTH_SERVER"],
                           url,
                           OAuth2::Client
  end
end

module RSpecFrontendServiceMixin
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      run FrontendService
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  WebMock.disable_net_connect!(
    allow_localhost: true,
    allow: %w[
      get-energy-performance-data
    ],
  )

  config.before { OauthStub.token }
  config.after { Capybara.reset_sessions! }
end

RSpec::Matchers.define(:redirect_to) do |path|
  match do |response|
    uri = URI.parse(response.headers["Location"])
    response.status.to_s[0] == "3" && uri.path == path
  end
end

RSpec::Matchers.define :match_html do |expected_html, **options|
  match do |actual_html|
    expected_doc = Nokogiri::HTML5.fragment(expected_html)
    actual_doc = Nokogiri::HTML5.fragment(actual_html)

    # Options documented here: https://github.com/vkononov/compare-xml
    default_options = {
      collapse_whitespace: true,
      ignore_attr_order: true,
      ignore_comments: true,
    }

    options = default_options.merge(options).merge(verbose: true)

    diff = CompareXML.equivalent?(expected_doc, actual_doc, **options)
    # account for leading spaces in class attributes as these are not significant
    diff.reject { |difference|
      %i[diff1 diff2].all? do |diff_ref|
        difference[diff_ref].include?("class")
      end && difference[:diff1].gsub(' "',
                                     '"') == difference[:diff2].gsub(' "', '"')
    }.empty?
  end
end

Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.app_host = "http://localhost:9393"
