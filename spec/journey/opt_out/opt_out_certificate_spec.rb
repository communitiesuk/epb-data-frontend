# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_context/shared_journey_context"

describe "Journey::OptOut::OptOutCertificate", :journey, type: :feature do
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

  describe "opting out as an owner" do
    before do
      visit_login_as_owner
      set_oauth_cookies
      visit "#{url}/name"
      set_name
      set_certificate_details
    end

    it "has the submitted information displayed on the '/check-your-answers' page" do
      expect(page).to have_current_path("/opt-out/check-your-answers")
      expect(page).to have_css(".govuk-summary-list__row #property-relationship-value", text: "Owner")
      expect(page).to have_css(".govuk-summary-list__row #full-name-value", text: "John Test")
      expect(page).to have_css(".govuk-summary-list__row #certificate-number-value", text: "1234-1234-1234-1234-1234")
      expect(page).to have_css(".govuk-summary-list__value", text: "Test Street")
      expect(page).to have_css(".govuk-summary-list__value", text: "London")
      expect(page).to have_css(".govuk-summary-list__value", text: "TE5 1NG")
    end

    context "when submitting the opt-out" do
      before do
        find(".govuk-checkboxes__item #confirmation", visible: :all).click
        click_button "Submit request"
      end

      it "redirects to the received page" do
        expect(page).to have_css("h1", text: "Request received")
      end

      context "when navigating back after submitting an opt-out" do
        it "redirects back to '/opt-out' page" do
          expect(page).to have_css("h1", text: "Request received")
          page.go_back
          click_button "Submit request"
          expect(page).to have_css("h1", text: "Opting out an EPC")
        end
      end
    end
  end

  describe "opting out as an occupant" do
    before do
      visit_opt_out_occupant
      find("#label-occupant_yes").click
      click_button "Continue"
      set_oauth_cookies
      visit "#{url}/name"
      set_name
      set_certificate_details
    end

    it "has the submitted information displayed on the '/check-your-answers' page" do
      expect(page).to have_current_path("/opt-out/check-your-answers")
      expect(page).to have_css(".govuk-summary-list__row #property-relationship-value", text: "Occupant")
    end

    it "allows them to submit the request" do
      find(".govuk-checkboxes__item #confirmation", visible: :all).click
      click_button "Submit request"
      expect(page).to have_css("h1", text: "Request received")
    end
  end
end
