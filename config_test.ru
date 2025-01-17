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

ENV["STAGE"] = "test"
ENV["EPB_UNLEASH_URI"] = "https://test-toggle-server/api"

run FrontendService.new
