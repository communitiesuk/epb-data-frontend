# frozen_string_literal: true

require "net/http"
require "zeitwerk"
require "webmock"
require "active_support"
require "webmock/rspec"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.push_dir("#{__dir__}/spec/test_doubles/")
loader.setup

WebMock.enable!

TogglesStub.enable(nil)
OauthStub.token

default_end_date = Date.new(Date.today.year.to_i, Date::MONTHNAMES.index((Date.today << 1).strftime("%B")) || 0, -1).to_s

CertificateCountStub.fetch(date_start: "2012-01-01", date_end: default_end_date)
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: "2025-03-31", council: %w[Adur], return_count: 10)
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: default_end_date, council: %w[Adur Birmingham])
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: default_end_date, constituency: %w[Ashford Barking])
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

ENV["STAGE"] = "test"
ENV["EPB_UNLEASH_URI"] = "https://test-toggle-server/api"
ENV["AWS_TEST_ACCESS_ID"] = "test.aws.id"
ENV["AWS_TEST_ACCESS_SECRET"] = "test.aws.secret"
ENV["SEND_DOWNLOAD_TOPIC_ARN"] = "arn:aws:sns:us-east-1:123456789012:testTopic"
AUTH_URL = "http://test-auth-server.gov.uk"
ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = AUTH_URL
ENV["EPB_DATA_WAREHOUSE_API_URL"] = "http://epb-data-warehouse-api"
ENV["AWS_S3_USER_DATA_BUCKET_NAME"] = "user-data"
ENV["ONELOGIN_HOST_URL"] = "http://localhost:3333"
ENV["ONELOGIN_CLIENT_ID"] = "HGIOgho9HIRhgoepdIOPFdIUWgewi0jw"
ENV["ONELOGIN_TLS_KEYS"] = OneLoginStub.tls_keys

run FrontendService.new
