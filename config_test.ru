# frozen_string_literal: true

require "net/http"
require "zeitwerk"
require "webmock"
require "active_support"
require "webmock/rspec"
require "aws-sdk-dynamodb"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.push_dir("#{__dir__}/spec/test_doubles/")
loader.setup

WebMock.enable!

WebMock.stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
       .to_return(status: 200,
                  body: {
                    id: "759b6a24-27bd-4fd3-80db-376e4eb8c391",
                    template: {
                      id: ENV["NOTIFY_OPT_OUT_TEMPLATE_ID"],
                      "version": 2,
                      "uri": "https://api.notifications.service.gov.uk/v2/template/#{ENV['NOTIFY_OPT_OUT_TEMPLATE_ID']}",
                    },
                  }.to_json,
                  headers: {})

TogglesStub.enable(nil)
OauthStub.token

default_end_date = Date.new(Date.today.year.to_i, Date::MONTHNAMES.index((Date.today << 1).strftime("%B")) || 0, -1).to_s

CertificateCountStub.fetch(date_start: "2012-01-01", date_end: default_end_date, property_type: "domestic")
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: "2025-03-31", council: %w[Adur], return_count: 10, property_type: "domestic")
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: default_end_date, council: %w[Adur Birmingham], property_type: "domestic")
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: default_end_date, constituency: %w[Ashford Barking], property_type: "domestic")
CertificateCountStub.fetch(date_start: "2012-01-01", date_end: default_end_date, postcode: "LS1 4AP", return_count: 135, property_type: "domestic")
CertificateCountStub.fetch_any

dynamodb_user = {
  "UserId" => "user_id",
  "OneLoginSub" => "sub_abcdef123",
  "BearerToken" => "token123",
  "CreatedAt" => "2025-03-05T11:00:00Z",
  "EmailAddress" => "encrypted-email",
  "OptOut" => false,
}

stubbed_dynamodb_client = Aws::DynamoDB::Client.new(stub_responses: true)

stubbed_dynamodb_client.stub_responses(
  :get_item,
  lambda { |_context| # ignore params completely
    { item: dynamodb_user }
  },
)

stubbed_dynamodb_client.stub_responses(:put_item, lambda { |context|
  # Convert AttributeValue → simple Ruby values
  item = context.params[:item].transform_values do |av|
    case av
    when Hash
      av[:s] || av[:bool] || av[:n] || (av[:null] && nil)
    else
      av
    end
  end
  dynamodb_user.merge!(item)
  { attributes: {} }
})

Aws.config[:dynamodb] = { client: stubbed_dynamodb_client }

sns_message =
  {
    "email_address" => "test@example.com",
    "property_type" => "domestic",
    "date_start" => "01-01-2021",
    "date_end" => "01-01-2022",
    "area" => {
      "councils" => %w[Aberdeen Angus],
    },
    "efficiency_ratings" => %w[A B C],
  }
SnsClientStub.fetch(message: sns_message)

class TestSessionInjector
  def initialize(app)
    @app = app
  end

  def call(env)
    session = env["rack.session"] ||= {}
    session[:user_id] = "user_id" unless session[:user_id]
    session[:email_address] = "test@example.com" unless session[:email_address]
    @app.call(env)
  end
end

use TestSessionInjector

ENV["SCRIPT_NONCE"] = SecureRandom.random_number(16**10).to_s(16).rjust(10, "0") if ENV["SCRIPT_NONCE"].nil?

ENV["STAGE"] = "test"
ENV["EPB_UNLEASH_URI"] = "https://test-toggle-server/api"
ENV["SEND_DOWNLOAD_TOPIC_ARN"] = "arn:aws:sns:us-east-1:123456789012:testTopic"
AUTH_URL = "http://test-auth-server.gov.uk"
ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = AUTH_URL
ENV["EPB_DATA_WAREHOUSE_API_URL"] = "http://epb-data-warehouse-api"
ENV["AWS_S3_USER_DATA_BUCKET_NAME"] = "user-data"
ENV["ONELOGIN_HOST_URL"] = "http://localhost:3333"
ENV["ONELOGIN_CLIENT_ID"] = "test.onelogin.client.id"
ENV["ONELOGIN_TLS_KEYS"] = OneLoginStub.tls_keys
ENV["SESSION_SECRET"] = "test_session_secret" * 4
ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"] = "dynamodb_test_table_name"
ENV["GTM_PROPERTY_FINDING"] = "G-H8EVD5HY3G"
ENV["LOCAL_SESSION"] = "true"
ENV["NOTIFY_OPT_OUT_TEMPLATE_ID"] = "f5d03031-b559-4264-8503-802ee0e78f4c"
ENV["NOTIFY_OPT_OUT_EMAIL_RECIPIENT"] = "opt-outs@example.com"
ENV["NOTIFY_DATA_API_KEY"] = "optoutrequest-658d1738-b6c2-426b-9215-a7a9b30ad44f-ec9bd43e-bf9b-41ef-9e11-43318a7d8c72"
ENV["PUBLISHED_DWH_API_URL"] = "http://api.get-energy-performance-data"
ENV["ALG"] = "RS256"
ENV["KMS_KEY_ID"] = "test-kms-key-id"

run FrontendService.new
