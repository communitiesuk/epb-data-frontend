describe "Acceptance::OptOutReason", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/reason" do
    let(:response) { get "#{base_url}/opt-out/reason" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    context "when the page is rendered" do
      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Why would you like to opt out your EPC?")
      end

      it "has the correct content for incorrect epc radio button" do
        expect(response.body).to have_css("label.govuk-label", text: "My EPC is incorrect")
      end

      it "has the correct content for epc advised radio button" do
        expect(response.body).to have_css("label.govuk-label", text: "I have been advised by someone else")
      end

      it "has the correct content for epc other radio button" do
        expect(response.body).to have_css("label.govuk-label", text: "Other / Prefer not to say")
      end

      it "has a warning message" do
        expect(response.body).to have_css("div.govuk-warning-text", text: "Opting out an EPC for the purpose of securing grant funding is fraud.")
      end

      it "has a continue button" do
        expect(response.body).to have_button("Continue")
      end
    end

    context "when submitting without selecting a reason" do
      let(:response) { post "#{base_url}/opt-out/reason" }

      it "contains the required GDS error summary" do
        expect(response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select a reason for opting out")
        expect(response.body).to have_link("Select a reason for opting out", href: "#reason-error")
      end
    end
  end
end
