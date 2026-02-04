# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_examples/shared_opt_out_error"

describe "Journey::OptOut::Name", :journey, type: :feature do
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

  context "when visiting the '/name' page" do
    before do
      visit_login
      set_user_login
    end

    context "when inputting full name in the input" do
      it "completes the POST and redirects to '/certificate-details' page" do
        visit "#{url}/name"
        fill_in "name", with: "John Test"
        click_button "Continue"
        expect(page).to have_current_path("/opt-out/certificate-details")
      end
    end

    context "when submitting without inputting full name" do
      before do
        visit "#{url}/name"
        click_button "Continue"
      end

      it_behaves_like "when checking error messages"
    end
  end
end
