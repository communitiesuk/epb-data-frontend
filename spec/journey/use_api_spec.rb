# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

describe "Journey::UseApi", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

  process_id = nil

  before(:all) do
    process = IO.popen(["rackup", "config_test.ru", "-q", "-o", "127.0.0.1", "-p", "9393", { err: %i[child out] }])
    process_id = process.pid
    loop { break if process.readline.include?("Listening on http://127.0.0.1:9393") }
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when visiting the '/use-api' page" do
    before do
      visit domain
      set_oauth_cookies
      find("a.govuk-button--start", text: "Start now").click
      visit "#{domain}/guidance/energy-certificate-data-apis"
    end

    it "displays the correct content" do
      expect(page).to have_selector("h1", text: "Energy certificate data APIs")
      expect(page).to have_selector("h2", text: "Data available")
      expect(page).to have_selector("h2", text: "Technical documentation")
      expect(page).to have_selector("h2", text: "My Bearer token")
      expect(page).to have_selector("h2", text: "Open API specification")
      expect(page).to have_selector("h2", text: "Conditions of use")
    end

    it "displays copy button for bearer token" do
      expect(page).to have_selector("button", text: "Copy")
    end

    it "shows 'Copied' feedback when copy button is clicked" do
      click_button "Copy"
      expect(page).to have_button("Copied", wait: 5)
    end

    context "when clicking the 'My account' link" do
      before do
        click_link "My account"
      end

      it "redirects to the account page" do
        expect(page).to have_current_path("#{domain}/api/my-account")
        expect(page).to have_selector("h1", text: "My account")
      end

      it "displays copy and sign out buttons" do
        expect(page).to have_link("Sign out")
        expect(page).to have_button("Copy")
      end
    end
  end
end
