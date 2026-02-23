# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

describe "Journey::DownloadAll", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

  process_id = nil

  before(:all) do
    process = IO.popen(["rackup", "config_test.ru", "-q", "-o", "127.0.0.1", "-p", "9393", { err: %i[child out] }])
    process_id = process.pid
    loop { break if process.readline.include?("Listening on http://127.0.0.1:9393") }
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when downloading all data from the filter properties page" do
    before do
      visit_filter_properties
      click_link "Download all"
    end

    it "redirects to the pre-signed URL" do
      expect(page).to have_current_path(%r{^/full-load/domestic-csv\.zip\?X-Amz-Algorithm=AWS4-HMAC-SHA256&.*})
    end
  end
end
