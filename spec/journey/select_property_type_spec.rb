# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"
require_relative "../shared_examples/shared_error"

describe "Journey::SelectPropertyType", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) do
    "http://get-energy-performance-data.epb-frontend:9393"
  end

  process_id = nil

  before(:all) do
    process = IO.popen(["rackup", "config_test.ru", "-q", "-o", "127.0.0.1", "-p", "9393", { err: %i[child out] }])
    process_id = process.pid
    loop { break if process.readline.include?("Listening on http://127.0.0.1:9393") }
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  before do
    visit_type_of_properties
  end

  context "when selecting domestic radio button" do
    context "when selecting a property type" do
      before do
        find("#label-domestic").click
        click_on "Continue"
      end

      it "shows the correct header for the filter property page" do
        expect(page).to have_selector("h1", text: "Domestic Energy Performance Certificates")
      end

      it "passes the property type in the query string" do
        expect(page.current_url).to include("?property_type=domestic")
      end
    end
  end

  context "when selecting non-domestic radio button" do
    context "when selecting a property type" do
      before do
        find("#label-non-domestic").click
        click_on "Continue"
      end

      it "shows the correct header for the filter property page" do
        expect(page).to have_selector("h1", text: "Non-domestic Energy Performance Certificates")
      end

      it "passes the property type in the query string" do
        expect(page.current_url).to include("?property_type=non-domestic")
      end
    end
  end

  context "when selecting display" do
    context "when selecting a property type" do
      before do
        find("#label-display").click
        click_on "Continue"
      end

      it "shows the correct header for the filter property page" do
        expect(page).to have_selector("h1", text: "Display Energy Certificates")
      end

      it "passes the property type in the query string" do
        expect(page.current_url).to include("?property_type=display")
      end
    end
  end

  context "when not selecting any property type" do
    before do
      click_on "Continue"
    end

    it_behaves_like "when checking GDS error messages"
  end
end
