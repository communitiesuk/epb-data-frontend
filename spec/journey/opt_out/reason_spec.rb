# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"

describe "Journey::OptOut::Reason", :journey, type: :feature do
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

  context "when visiting the opt out" do
    before do
      visit_opt_out_reason
    end

    context "when selecting the 'other' reason" do
      before do
        find("#label-epc_other").click
        click_button "Continue"
      end

      it "shows the '/owner' page" do
        expect(page).to have_current_path("/opt-out/owner")
        expect(page).to have_css("h1", text: "Are you the legal owner of the property")
      end
    end

    context "when selecting the 'My EPC is incorrect' reason" do
      before do
        find("#label-epc_incorrect").click
        click_button "Continue"
      end

      it "shows the '/incorrect-epc' page" do
        expect(page).to have_current_path("/opt-out/incorrect-epc")
        expect(page).to have_css("h1", text: "What to do if your EPC is incorrect")
      end
    end

    context "when selecting the 'advised by someone else' reason" do
      before do
        find("#label-epc_advised").click
        click_button "Continue"
      end

      it "shows the '/epc_advise' page" do
        expect(page).to have_current_path("/opt-out/advised-by-third-party")
        expect(page).to have_css("h1", text: "You do not need to opt out to access grant funding")
      end
    end
  end
end
