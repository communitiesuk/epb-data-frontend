describe "Acceptance::RequestReceivedConfirmation", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/request-received-confirmation"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/request-received-confirmation" do
    context "when the data access options page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/"
      end

      it "the title to be correct" do
        expect(response.body).to have_selector("h2", text: "Request received")
        expect(response.body).to have_selector("p.govuk-body", text: "This may take up to 15 minutes to be delivered to your inbox.")
      end
    end
  end
end
