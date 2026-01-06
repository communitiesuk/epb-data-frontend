# frozen_string_literal: true

describe "Journey::OptOut::Reason", :journey, type: :feature do
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
      visit url
      find(".govuk-button").click
    end

    context "when selecting the incorrect EPC radio button" do
      it "shows the incorrect EPC page" do
        find("#label-epc_incorrect").click
        find("button").click
        expect(page).to have_css("h1", text: "What to do if your EPC is incorrect")
      end
    end

    context "when selecting the advised EPC radio button" do
      it "shows the advised EPC page" do
        find("#label-epc_advised").click
        find("button").click
        expect(page).to have_css("h1", text: "You do not need to opt out to access grant funding")
      end
    end

    context "when selecting the 'other' radio button" do
      it "shows the owner page" do
        find("#label-epc_other").click
        find("button").click
        expect(page).to have_css("h1", text: "Are you the legal owner of the property")
        expect(page).to have_css(".govuk-radios__item #label-yes", text: "Yes")
      end
    end
  end
end
