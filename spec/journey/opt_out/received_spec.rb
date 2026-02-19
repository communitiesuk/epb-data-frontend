# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"
require_relative "../../shared_examples/shared_error"
require_relative "../../shared_context/shared_journey_context"

describe "Journey::OptOut::Received", :journey, type: :feature do
  include_context "when setting up journey tests"
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

    context "when selecting the 'other' radio button" do
      before do
        find("#label-epc_other").click
        click_button "Continue"
      end

      it "completes the POST and redirects to the '/owner' page" do
        expect(page).to have_current_path("/opt-out/owner")
      end

      context "when visiting the owner page" do
        context "when selecting the 'yes' radio button" do
          before do
            find("#label-yes").click
            click_button "Continue"
          end

          it "completes the POST and redirects to 'login' page" do
            expect(page).to have_current_path("/login?referer=opt-out")
          end

          context "when visiting the '/name' page" do
            before do
              set_oauth_cookies
              visit "#{url}/name"
            end

            context "when submitting without inputting full name" do
              before do
                click_button "Continue"
              end

              it_behaves_like "when checking error messages"
            end

            context "when inputting full name in the input" do
              before do
                fill_in "name", with: "John Test"
                click_button "Continue"
              end

              it "completes the POST and redirects to '/certificate-details' page" do
                expect(page).to have_current_path("/opt-out/certificate-details")
              end

              context "when submitting without inputting anything" do
                before do
                  click_button "Continue"
                end

                it_behaves_like "when checking error messages"
              end

              context "when visiting the '/certificate-details' page" do
                before do
                  fill_in "certificate_number", with: "1234-1234-1234-1234-1234"
                  fill_in "address-line1", with: "Test Street"
                  fill_in "address-town", with: "London"
                  fill_in "address-postcode", with: "TE5 1NG"
                  click_button "Continue"
                end

                it "completes the POST and redirects to '/check-your-answers'" do
                  expect(page).to have_current_path("/opt-out/check-your-answers")
                end

                context "when visiting the '/check-your-answers' page and submitting an opt-out" do
                  before do
                    find(".govuk-checkboxes__item #confirmation", visible: :all).click
                    click_button "Submit request"
                  end

                  it "redirects to the received page" do
                    expect(page).to have_css("h1", text: "Request received")
                  end

                  context "when navigating back after submitting an opt-out" do
                    it "redirects back to '/opt-out' page" do
                      expect(page).to have_css("h1", text: "Request received")
                      page.go_back
                      click_button "Submit request"
                      expect(page).to have_css("h1", text: "Opting out an EPC")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
