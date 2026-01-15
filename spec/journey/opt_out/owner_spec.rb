# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"

describe "Journey::OptOut::Owner", :journey, type: :feature do
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

  context "when visiting the owner page" do
    before do
      visit_opt_out_owner
    end

    context "when selecting 'yes' on the owner page" do
      before do
        find("#label-yes").click
        click_button "Continue"
      end

      it "shows login page" do
        expect(page).to have_current_path("/login?referer=opt-out")
        expect(page).to have_css("h1", text: "Create your GOV.UK One Login or sign in")
      end

      it "persists the session cookie" do
        browser_cookie = Capybara.current_session.driver.browser.manage.all_cookies
        expect(browser_cookie).to include(a_hash_including(name: "epb_data.session"))
      end
    end

    context "when selecting 'no' on the owner page" do
      before do
        find("#label-no").click
        click_button "Continue"
      end

      it "shows '/occupant' page" do
        expect(page).to have_current_path("/opt-out/occupant")
        expect(page).to have_css("h1", text: "Do you live in the property that you want to opt-out?")
      end
    end
  end
end
