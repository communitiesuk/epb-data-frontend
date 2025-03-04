describe "Acceptance::DataAccessOptionsPage", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/data_access_options"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/data_access_options" do
    context "when the data access options page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/"
      end

      it "the title to be correct" do
        expect(response.body).to have_selector("h1", text: "How would you like to access the data?")
      end

      it "has the correct content for download files option" do
        expect(response.body).to have_selector("h2.govuk-heading-m", text: "Download files")
        expect(response.body).to have_selector("p.govuk-body", text: "Download certificate data which can be opened in Microsoft Excel.")
        expect(response.body).to have_link("Download files", href: "/type-of-properties")
      end

      it "has the correct content for use api option" do
        expect(response.body).to have_selector("h2.govuk-heading-m", text: "Use a developer API")
        expect(response.body).to have_selector("p.govuk-body", text: "Use an API to access certificate data.")
        expect(response.body).to have_link("Use API", href: "/use-api")
      end
    end
  end
end
