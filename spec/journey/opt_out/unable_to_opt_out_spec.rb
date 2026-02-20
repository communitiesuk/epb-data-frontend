# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"

describe "Journey::OptOut::UnableToOptOut", :journey, type: :feature do
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

  context "when giving the reason 'advised by someone else'" do
    before do
      visit_opt_out_reason
      find("#label-epc_advised").click
      click_button "Continue"
    end

    it "completes the POST and redirects to the '/epc_advise' page" do
      expect(page).to have_current_path("/opt-out/advised-by-third-party")
    end
  end

  context "when giving the reason 'My EPC is incorrect'" do
    before do
      visit_opt_out_reason
      find("#label-epc_incorrect").click
      click_button "Continue"
    end

    it "completes the POST and redirects to the '/epc_advise' page" do
      expect(page).to have_current_path("/opt-out/incorrect-epc")
    end
  end

  context "when attempting to opt out but are neither an owner or occupier" do
    before do
      visit_opt_out_owner
    end

    context "when they are not the owner" do
      before do
        find("#label-no").click
        click_button "Continue"
      end

      it "completes the POST and redirects to '/occupant' page" do
        expect(page).to have_current_path("/opt-out/occupant")
      end

      context "when they are not an occupant" do
        before do
          find("#label-occupant_no").click
          click_button "Continue"
        end

        it "completes the POST and redirects to '/ineligible' page" do
          expect(page).to have_current_path("/opt-out/ineligible")
        end
      end
    end
  end

  context "when attempting to skip over pages" do
    %w[owner occupant name certificate-details check-your-answers received].each do |endpoint|
      it "redirects to '/opt-out' page when visiting /opt-out/#{endpoint} without session data" do
        visit "/opt-out/#{endpoint}"
        expect(page).not_to have_current_path("/opt-out/#{endpoint}")

        expect(page).to have_current_path("/opt-out")
        expect(page).to have_css("h1", text: "Opting out an EPC")
      end
    end
  end
end
