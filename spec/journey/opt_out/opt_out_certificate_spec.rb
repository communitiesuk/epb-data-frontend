# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_context/shared_journey_context"

describe "Journey::OptOut::OptOutCertificate", :journey, type: :feature do
  include_context "when setting up journey tests"
  include_context "when testing the opt out process"

  let(:url) do
    "http://get-energy-performance-data.epb-frontend:9393/opt-out"
  end

  describe "opting out as an owner" do
    before do
      visit_login_as_owner
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
        check "I confirm that these details are correct", allow_label_click: true
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
      within_fieldset "Do you live in the property that you want to opt-out?" do
        choose "Yes", allow_label_click: true
      end
      click_button "Continue"
      find "h1", text: "Create your GOV.UK One Login or sign in"
      visit "#{url}/name"
      set_name
      set_certificate_details
    end

    it "has the submitted information displayed on the '/check-your-answers' page" do
      expect(page).to have_current_path("/opt-out/check-your-answers")
      expect(page).to have_css(".govuk-summary-list__row #property-relationship-value", text: "Occupant")
    end

    it "allows them to submit the request" do
      check "I confirm that these details are correct", allow_label_click: true
      click_button "Submit request"
      expect(page).to have_css("h1", text: "Request received")
    end
  end
end
