# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

describe "Journey::DownloadAll", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

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
