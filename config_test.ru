# frozen_string_literal: true

require "net/http"
require "zeitwerk"
require "webmock"
require "active_support"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.push_dir("#{__dir__}/spec/test_doubles/")
loader.setup

WebMock.enable!

TogglesStub.enable(nil)

OauthStub.token

ENV["STAGE"] = "test"
ENV["EPB_UNLEASH_URI"] = "https://test-toggle-server/api"
ENV["AWS_TEST_ACCESS_ID"] = "test.aws.id"
ENV["AWS_TEST_ACCESS_SECRET"] = "test.aws.secret"

AUTH_URL = "http://test-auth-server.gov.uk"

ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = AUTH_URL
ENV["EPB_DATA_WAREHOUSE_API_URL"] = "http://epb-data-warehouse-api"
ENV["AWS_S3_USER_DATA_BUCKET_NAME"] = "user-data"
run FrontendService.new
