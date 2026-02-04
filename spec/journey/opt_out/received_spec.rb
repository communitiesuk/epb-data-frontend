# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_examples/shared_opt_out_error"

describe "Journey::OptOut::Received", :journey, type: :feature do
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

  context "when visiting the submitting and opt-out" do
    before do
      visit_login
      set_user_login
      visit "#{url}/name"
      fill_in "name", with: "John Test"
      click_button "Continue"
      fill_in "certificate_number", with: "1234-1234-1234-1234-1234"
      fill_in "address-line1", with: "Test Street"
      fill_in "address-town", with: "London"
      fill_in "address-postcode", with: "TE5 1NG"
      click_button "Continue"
    end

    it "redirects to the received page after submitting" do
      find(".govuk-checkboxes__item #confirmation", visible: :all).click
      click_button "Submit request"
      expect(page).to have_css("h1", text: "Request received")
    end

    context "when navigating back after submitting an opt-out" do
      it "redirects back to '/opt-out' page" do
        find(".govuk-checkboxes__item #confirmation", visible: :all).click
        click_button "Submit request"
        expect(page).to have_css("h1", text: "Request received")
        page.go_back
        click_button "Submit request"
        expect(page).to have_css("h1", text: "Opting out an EPC")
      end
    end
  end
end
