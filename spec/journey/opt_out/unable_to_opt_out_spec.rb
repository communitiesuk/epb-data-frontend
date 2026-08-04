# frozen_string_literal: true

require_relative "../../shared_context/shared_opt_out_context"

describe "Journey::OptOut::UnableToOptOut", :journey, type: :feature do
  include_context "when testing the opt out process"

  let(:url) do
    "http://get-energy-performance-data.epb-frontend:9393/opt-out"
  end

  context "when giving the reason 'advised by someone else'" do
    before do
      visit_opt_out_reason
      within_fieldset "Why would you like to opt out your EPC?" do
        choose "I have been advised by someone else", allow_label_click: true
      end
      click_button "Continue"
    end

    it "completes the POST and redirects to the '/epc_advise' page" do
      expect(page).to have_current_path("/opt-out/advised-by-third-party")
    end
  end

  context "when giving the reason 'My EPC is incorrect'" do
    before do
      visit_opt_out_reason
      within_fieldset "Why would you like to opt out your EPC?" do
        choose "My EPC is incorrect", allow_label_click: true
      end
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
        within_fieldset "Are you the legal owner of the property that you want to opt out?" do
          choose "No", allow_label_click: true
        end
        click_button "Continue"
      end

      it "completes the POST and redirects to '/occupant' page" do
        expect(page).to have_current_path("/opt-out/occupant")
      end

      context "when they are not an occupant" do
        before do
          within_fieldset "Do you live in the property that you want to opt-out?" do
            choose "No", allow_label_click: true
          end
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
