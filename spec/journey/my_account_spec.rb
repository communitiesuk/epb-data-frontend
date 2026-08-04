# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

describe "Journey::MyAccount", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

  context "when visiting the '/api/my-account' page" do
    before do
      visit domain
      click_link "Start now"
      visit "#{domain}/api/my-account"
    end

    it "displays the correct content" do
      expect(page).to have_selector("h1", text: "My account")
      expect(page).to have_selector("#email-address dt", text: "Email address")
      expect(page).to have_selector("#bearer-token dt", text: "Bearer token (for developers)")
      expect(page).to have_selector("#opt-out dt", text: "Email notifications")
    end

    it "displays copy button for bearer token" do
      expect(page).to have_button "Copy"
    end

    it "shows 'Copied' feedback when copy button is clicked" do
      click_button "Copy"
      expect(page).to have_button "Copied"
    end

    it "displays unsubscribe email notifications link" do
      expect(page).to have_link "Unsubscribe"
    end

    it "displays the email notifications status description" do
      expect(page).to have_selector("#subscription-value", text: "You will get emails about changes to the service.")
    end

    context "when clicking the 'Unsubscribe' link" do
      it "updates email notifications status and link" do
        click_link "Unsubscribe"
        expect(page).to have_link "Resubscribe"
        expect(page).to have_selector("#subscription-value", text: "You have unsubscribed from emails about changes to the service.")
      end
    end
  end
end
