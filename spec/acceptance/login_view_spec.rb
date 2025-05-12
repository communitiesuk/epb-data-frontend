describe "Acceptance::Login", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/login"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/login" do
    context "when the request received login page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/data-access-options"
      end

      it "shows the correct title and body text" do
        expect(response.body).to have_selector("h1", text: "Get energy certificate data")
        expect(response.body).to have_selector("p.govuk-body", text: "You'll need a GOV.UK One Login to use this service. If you do not have a GOV.UK One Login, you can create one.")
      end

      it "has the correct Start now button" do
        expect(response.body).to have_link("Start now", href: "#")
      end
    end
  end
end
