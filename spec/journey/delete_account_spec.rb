# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

describe "Journey::DeleteAccount", :journey, type: :feature do
  include_context "when setting up journey tests"

  context "when visiting the '/api/my-account/delete-account' page" do
    before do
      visit "/"
      click_link "Start now"
      visit "/api/my-account/delete-account"
    end

    it "displays the correct heading" do
      expect(page).to have_selector("h1.govuk-heading-xl", text: "Delete your account")
    end

    it "displays the warning delete button" do
      expect(page).to have_button "Delete account"
    end

    context "when clicking the 'Cancel' link" do
      it "returns to the my account page" do
        click_link "Cancel"
        expect(page).to have_current_path("/api/my-account")
        expect(page).to have_selector("h1", text: "My account")
      end
    end

    context "when clicking the 'Delete account' button" do
      it "redirects to the account deleted confirmation page" do
        click_button "Delete account"
        expect(page).to have_current_path("/account-deleted")
        expect(page).to have_selector("h1.govuk-heading-xl", text: "Delete your account")
        expect(page).to have_content("Your account has been deleted.")
      end
    end
  end
end
