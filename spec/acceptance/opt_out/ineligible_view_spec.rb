describe "Acceptance::OptOutIneligible", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/ineligible" do
    let(:response) { get "#{base_url}/opt-out/ineligible" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    context "when the page is rendered" do
      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "You are not eligible to opt out")
      end

      it "has the correct text" do
        expect(response.body).to have_css("p", text: "You must own or live in the property to opt-out an EPC.")
      end
    end
  end
end
