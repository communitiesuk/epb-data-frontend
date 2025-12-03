describe "Acceptance::OptOccupant", type: :feature do
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
end
