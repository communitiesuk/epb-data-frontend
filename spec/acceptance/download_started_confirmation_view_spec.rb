describe "Acceptance::DownloadStartedConfirmation", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/download-started-confirmation"
  end

  let(:response) { get "#{local_host}?property_type=domestic" }

  describe "get .get-energy-certificate-data.epb-frontend/download-started-confirmation" do
    context "when the download started confirmation page is rendered" do
      before do
        Timecop.freeze(Time.utc(2025, 4, 15))
      end

      after do
        Timecop.return
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/filter-properties?property_type=domestic"
      end

      it "the title to be correct" do
        expect(response.body).to have_selector("h2", text: "Download started")
      end

      it "shows correct content for the requested data" do
        expect(response.body).to have_css(".govuk-body", text: "You requested data for:")
        expect(response.body).to have_css(".govuk-body", text: "Energy Performance Certificates and recommendations")
        expect(response.body).to have_css(".govuk-body", text: "January 2012 - March 2025")
        expect(response.body).to have_css(".govuk-body", text: "England and Wales")
        expect(response.body).to have_css(".govuk-body", text: "Energy Efficiency Rating A, B, C, D, E, F, G")
      end
    end
  end
end
