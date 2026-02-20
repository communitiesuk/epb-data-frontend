# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_examples/shared_error"
require_relative "../../shared_context/shared_journey_context"

describe "Journey::OptOut::EditingAnswers", :journey, type: :feature do
  include_context "when setting up journey tests"
  include_context "when testing the opt out process"
  let(:url) do
    "http://get-energy-performance-data.epb-frontend:9393/opt-out"
  end

  process_id = nil

  before(:all) do
    process =
      IO.popen(
        [
          "rackup",
          "config_test.ru",
          "-q",
          "-o",
          "127.0.0.1",
          "-p",
          "9393",
          { err: %i[child out] },
        ],
      )
    process_id = process.pid

    # Wait until the Puma server has started up before beginning tests
    loop do
      break if process.readline.include?("Listening on http://127.0.0.1:9393")
    end
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when editing responses on the '/check-your-answers' page" do
    before do
      visit_login_as_owner
      set_oauth_cookies
      visit "#{url}/name"
      set_name
      set_certificate_details
    end

    context "when editing the name" do
      it "updates to the new name on the summary page" do
        click_link "Change name"
        fill_in "name", with: "New Tester"
        click_button "Continue"
        click_button "Continue"
        expect(page).to have_css(".govuk-summary-list__row #full-name-value", text: "New Tester")
      end
    end

    context "when changing the relationship to the property" do
      before do
        click_link "Change owner"
        visit_opt_out_occupant
      end

      it "updates on the summary page" do
        find("#label-occupant_yes").click
        click_button "Continue"
        set_oauth_cookies
        visit "#{url}/name"
        click_button "Continue"
        click_button "Continue"
        expect(page).to have_css(".govuk-summary-list__row #property-relationship-value", text: "Occupant")
      end

      context "when changing the relationship to be neither an occupant or owner" do
        it "sends the user to the ineligible page" do
          find("#label-occupant_no").click
          click_button "Continue"
          expect(page).to have_current_path("/opt-out/ineligible")
        end
      end
    end

    context "when editing the certificate number" do
      it "updates to the new certificate number on the summary page" do
        click_link "Change certificate number"
        fill_in "certificate_number", with: "2345-2345-2345-2345-2345"
        click_button "Continue"
        expect(page).to have_css(".govuk-summary-list__row #certificate-number-value", text: "2345-2345-2345-2345-2345")
      end
    end

    context "when editing the address" do
      it "updates to the new address on the summary page" do
        click_link "Change property address"
        fill_in "address-line1", with: "Flat 1"
        fill_in "address-line-2", with: "1 Test Street"
        click_button "Continue"
        expect(page).to have_css(".govuk-summary-list__value", text: "Flat 1")
        expect(page).to have_css(".govuk-summary-list__value", text: "1 Test Street")
        expect(page).to have_css(".govuk-summary-list__value", text: "London")
        expect(page).to have_css(".govuk-summary-list__value", text: "TE5 1NG")
      end
    end
  end
end
