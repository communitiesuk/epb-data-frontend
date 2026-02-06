# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_examples/shared_opt_out_error"

describe "Journey::OptOut::IncorrectEPC", :journey, type: :feature do
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

  context "when visiting the opt out reason page" do
    before do
      visit_opt_out_reason
    end

    context "when selecting the 'My EPC is incorrect' radio button" do
      before do
        find("#label-epc_incorrect").click
        click_button "Continue"
      end

      it "completes the POST and redirects to the '/incorrect-epc' page" do
        expect(page).to have_current_path("/opt-out/incorrect-epc")
      end
    end

    context "when submitting without selecting a radio button" do
      before do
        click_button "Continue"
      end

      it_behaves_like "when checking error messages"
    end

    context "when visiting the '/check-your-answers' page without valid session values" do
      before do
        visit "#{url}/check-your-answers"
      end

      it "redirects to '/opt-out' page" do
        expect(page).to have_css("h1", text: "Opting out an EPC")
      end
    end
  end
end
