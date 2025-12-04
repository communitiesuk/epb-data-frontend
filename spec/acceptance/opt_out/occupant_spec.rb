describe "Acceptance::OptOutOccupant", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/occupant" do
    let(:response) { get "#{base_url}/opt-out/occupant" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "displays the title as expected" do
      expect(response.body).to have_css("h1", text: "Do you live in the property that you want to opt-out?")
    end

    it "has the correct content for yes I live in the property radio button" do
      expect(response.body).to have_css("label.govuk-label", text: "Yes")
    end

    it "has the correct content for no I do not live in the property radio button" do
      expect(response.body).to have_css("label.govuk-label", text: "No")
    end

    it "has a continue button" do
      expect(response.body).to have_button("Continue")
    end

    context "when submitting without selecting whether occupant or not" do
      let(:response) { post "#{base_url}/opt-out/occupant" }

      it "contains the required GDS error summary" do
        expect(response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select if you live in the property")
        expect(response.body).to have_link("Select if you live in the property", href: "#occupant-error")
      end
    end
  end

  describe "post .get-energy-certificate-data.epb-frontend/opt-out/owner" do
    before do
      allow(Helper::Session).to receive(:set_session_value)
    end

    context "when yes radio button is selected" do
      let(:response) { post "#{base_url}/opt-out/occupant", { occupant: "occupant_yes" } }

      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(response.location).to include("/login?referer=opt-out")
      end

      it "has the session value" do
        response
        expect(Helper::Session).to have_received(:set_session_value).with(anything, :opt_out, { occupant: "yes" })
      end
    end

    context "when the 'no' radio button is selected" do
      let(:response) { post "#{base_url}/opt-out/occupant", { occupant: "occupant_no" } }

      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(response.location).to include("/opt-out/ineligible")
      end

      it "has the session value" do
        response
        expect(Helper::Session).to have_received(:set_session_value).with(anything, :opt_out, { occupant: "no" })
      end
    end
  end
end
