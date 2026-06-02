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
  end
end
