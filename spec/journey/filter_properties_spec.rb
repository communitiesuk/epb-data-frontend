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

  context "when navigating to the filter properties page" do
    before do
      visit_type_of_properties
      find("#label-domestic").click
      click_button "Continue"
    end

    context "when downloading all data" do
      before { click_link "Download all" }

      it "redirects to the pre-signed URL" do
        expect(page).to have_current_path(%r{^/full-load/domestic-csv\.zip\?X-Amz-Algorithm=AWS4-HMAC-SHA256&.*})
      end
    end

    context "when downloading selected data" do
      before do
        find(".govuk-accordion__show-all").click
        select "May", from: "from-month"
        select "2024", from: "from-year"
        select "December", from: "to-month"
        select "2025", from: "to-year"
        uncheck_efficiency_ratings(ratings: %w[A B])
      end

      it "displays correct filters on the confirmation page" do
        click_on "Download selected"
        expect(page).to have_content("Domestic Energy Performance Certificates")
        expect(page).to have_content("May 2024 - December 2025")
        expect(page).to have_content("Energy Efficiency Rating C, D, E, F, G")
      end

      context "when filtering by local authority" do
        before do
          la_input = find("input#local-authority")
          la_input.click
          la_input.send_keys("Adur", :enter, "Birmingham", :enter)
          click_on "Download selected"
        end

        it "displays correct filter on the confirmation page" do
          expect(page).to have_content("Domestic Energy Performance Certificates")
          expect(page).to have_content("May 2024 - December 2025")
          expect(page).to have_content("Adur, Birmingham")
          expect(page).to have_content("Energy Efficiency Rating C, D, E, F, G")
        end
      end

      context "when filtering by parliamentary constituency" do
        before do
          find("input#area-2.govuk-radios__input", visible: :all).click
          pc_input = find("input#parliamentary-constituency")
          pc_input.click
          pc_input.send_keys("Banbury", :enter, "Mansfield", :enter)
          click_on "Download selected"
        end

        it "displays correct filter on the confirmation page" do
          expect(page).to have_content("Banbury, Mansfield")
        end
      end

      context "when filtering by postcode" do
        before do
          find("input#area-3.govuk-radios__input", visible: :all).click
          fill_in "postcode", with: "M4 5LA"
          click_on "Download selected"
        end

        it "displays correct filter on the confirmation page" do
          expect(page).to have_content("M4 5LA")
        end
      end
    end

    context "when downloading selected data without providing filters" do
      before { click_on "Download selected" }

      it "defaults to download all files" do
        expect(page).to have_current_path(%r{^/full-load/domestic-csv\.zip\?X-Amz-Algorithm=AWS4-HMAC-SHA256&.*})
      end
    end

    context "when downloading selected data with invalid filters" do
      context "when start date is after end date" do
        before do
          find(".govuk-accordion__show-all").click
          select "May", from: "from-month"
          select "2025", from: "from-year"
          select "December", from: "to-month"
          select "2024", from: "to-year"
          click_on "Download selected"
        end

        it_behaves_like "when checking GDS error messages"
      end

      context "when none of the efficiency ratings is selected" do
        before do
          find(".govuk-accordion__show-all").click
          uncheck_efficiency_ratings
          click_on "Download selected"
        end

        it_behaves_like "when checking GDS error messages"
      end
    end
  end

  context "when navigating to the filter properties page with invalid property type in the params" do
    before do
      visit "#{domain}/filter-properties?property_type=invalid"
    end

    it_behaves_like "when checking 404 error message"
  end
end
