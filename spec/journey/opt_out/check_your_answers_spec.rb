# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_examples/shared_error"
require_relative "../../shared_context/shared_journey_context"

describe "Journey::OptOut::CheckYourAnswers", :journey, type: :feature do
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

  context "when visiting the '/check-your-answers' page" do
    before do
      visit_login
      set_oauth_cookies
      visit "#{url}/name"
      fill_in "name", with: "John Test"
      click_button "Continue"
      fill_in "certificate_number", with: "1234-1234-1234-1234-1234"
      fill_in "address-line1", with: "Test Street"
      fill_in "address-town", with: "London"
      fill_in "address-postcode", with: "TE5 1NG"
      click_button "Continue"
    end

    it "allows you to change your name" do
      click_link "Change name"
      fill_in "name", with: "New Tester"
      click_button "Continue"
      click_button "Continue"
      expect(page).to have_css(".govuk-summary-list__row #full-name-value", text: "New Tester")
    end

    it "allows you to change your relationship to property" do
      click_link "Change owner"
      visit_opt_out_occupant
      find("#label-occupant_yes").click
      click_button "Continue"
      set_oauth_cookies
      visit "#{url}/name"
      click_button "Continue"
      click_button "Continue"
      expect(page).to have_css(".govuk-summary-list__row #property-relationship-value", text: "Occupant")
    end

    it "allows you to change your certificate number" do
      click_link "Change certificate number"
      fill_in "certificate_number", with: "2345-2345-2345-2345-2345"
      click_button "Continue"
      expect(page).to have_css(".govuk-summary-list__row #certificate-number-value", text: "2345-2345-2345-2345-2345")
    end
  end
end
