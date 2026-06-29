describe "Acceptance::DataAccessOptions", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/data-access-options"
  end

  let(:response) { get local_host }
  let(:download_files_response) { get "#{local_host}/login" }

  describe "get .get-energy-certificate-data.epb-frontend/data-access-options" do
    context "when the data access options page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/"
      end

      it "shows the correct header" do
        expect(response.body).to have_selector("h1", text: "How would you like to access the data?")
      end

      it "displays the title the same as the main header value" do
        expect(response.body).to have_title "How would you like to access the data? – GOV.UK"
      end
    end

    context "when submitting with an access type" do
      it "routes to the login page with a /property-types referer if Download files is selected" do
        response = post "http://get-energy-performance-data/data-access-options", { access_type: "download" }
        expect(response.status).to eq(302)
        expect(response.location).to eq "http://get-energy-performance-data/login/authorize?referer=type-of-properties"
      end

      it "routes to the api page if Use a developer API is selected" do
        response = post "http://get-energy-performance-data/data-access-options", { access_type: "api" }
        expect(response.status).to eq(302)
        expect(response.location).to eq "http://get-energy-performance-data/guidance/energy-certificate-data-apis"
      end
    end

    context "when submitting without an access type" do
      it "contains the required GDS error summary" do
        response = post "http://get-energy-performance-data/data-access-options"
        expect(response.status).to eq(200)
        expect(response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select how you would like to access the data")
        expect(response.body).to have_link("Select how you would like to access the data", href: "#data_access_options-error")
        expect(response.body).to have_title "Error: How would you like to access the data? – GOV.UK", exact: true
      end
    end
  end
end
