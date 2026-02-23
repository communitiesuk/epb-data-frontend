# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"
require_relative "../shared_examples/shared_error"

describe "Journey::FilterProperties", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

  process_id = nil

  before(:all) do
    process = IO.popen(["rackup", "config_test.ru", "-q", "-o", "127.0.0.1", "-p", "9393", { err: %i[child out] }])
    process_id = process.pid
    loop { break if process.readline.include?("Listening on http://127.0.0.1:9393") }
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  before do
    visit_filter_properties
  end

  context "when navigating to the filter properties page" do
    it "displays correct content" do
      expect(page).to have_content("Domestic Energy Performance Certificates")
      expect(page).to have_content("Filter certificates (optional)")
      expect(page).to have_content("Use the filters to select the data you need.")
    end

    it "displays a download buttons" do
      expect(page).to have_link("Download all")
      expect(page).to have_button("Download selected")
    end
  end

  context "when navigating to the filter properties page with invalid property type in the params" do
    before do
      visit "#{domain}/filter-properties?property_type=invalid"
    end

    it_behaves_like "when checking 404 error message"
  end
end
