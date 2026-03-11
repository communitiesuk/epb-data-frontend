# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

describe "Journey::MyAccount", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

  process_id = nil

  before(:all) do
    process = IO.popen(["rackup", "config_test.ru", "-q", "-o", "127.0.0.1", "-p", "9393", { err: %i[child out] }])
    process_id = process.pid
    loop { break if process.readline.include?("Listening on http://127.0.0.1:9393") }
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when visiting the '/api/my-account' page" do
    before do
      visit domain
      set_oauth_cookies
      find("a.govuk-button--start", text: "Start now").click
      visit "#{domain}/api/my-account"
    end

    it "displays the correct content" do
      expect(page).to have_selector("h1", text: "My account")

      expect(page).to have_selector("#email-address dt", text: "Email address")
      expect(page).to have_selector("#bearer-token dt", text: "Bearer token (for developers)")
      expect(page).to have_selector("#opt-out dt", text: "Email notifications")
    end

    it "displays copy button for bearer token" do
      expect(page).to have_selector("button", text: "Copy")
    end

    it "shows 'Copied' feedback when copy button is clicked" do
      click_button "Copy"
      expect(page).to have_button("Copied", wait: 5)
    end

    it "displays opt-out email notifications link" do
      expect(page).to have_selector("#opt-out-toggle-link", text: "Opt-out")
    end

    it "displays the email notifications status description" do
      expect(page).to have_selector("#opt-out-value", text: "You may get email notifications about changes to the service.")
    end

    context "when clicking the 'Opt-out' link" do
      it "updates email notifications status and link" do
        click_link("opt-out-toggle-link")
        expect(page).to have_selector("#opt-out-toggle-link", text: "Opt-in")
        expect(page).to have_selector("#opt-out-value", text: "You have opted out of email notifications about changes to the service.")
      end
    end
  end
end
