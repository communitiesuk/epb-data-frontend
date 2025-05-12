describe "Acceptance::DataAccessOptions", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/data-access-options"
  end

  let(:response) { get local_host }
  let(:submit_response) { post local_host }

  describe "get .get-energy-certificate-data.epb-frontend/data-access-options" do
    context "when the data access options page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/"
      end

      it "shows the correct title" do
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

    context "when the epb-frontend-data-restrict-user-access feature toggle is on" do
      before do
        Helper::Toggles.set_feature("epb-frontend-data-restrict-user-access", true)
      end

      it "returns 302" do
        expect(submit_response.status).to eq(302)
      end

      it "the response location will be filter properties page" do
        expect(submit_response.headers["location"]).to include("/login")
      end
    end

    context "when the epb-frontend-data-restrict-user-access feature toggle is off" do
      before do
        Helper::Toggles.set_feature("epb-frontend-data-restrict-user-access", false)
      end

      it "returns 302" do
        expect(submit_response.status).to eq(302)
      end

      it "the response location will be filter properties page" do
        expect(submit_response.headers["location"]).to include("/type-of-properties")
      end
    end
  end
end
