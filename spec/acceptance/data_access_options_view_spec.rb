describe "Acceptance::DataAccessOptionsPage", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/data_access_options_page"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/data_access_options" do
    context "when the data access options page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "the title to be correct" do
        expect(response.body).to have_selector("h1", text: I18n.t("data_access_options_page.title"))
      end

      it "has the correct content for download files option" do
        expect(response.body).to have_selector("h2.govuk-heading-m", text: I18n.t("data_access_options_page.download_files.title"))
        expect(response.body).to have_selector("p.govuk-body", text: I18n.t("data_access_options_page.download_files.description"))
        expect(response.body).to have_link(I18n.t("data_access_options_page.download_files.button_text"), href: "/type-of-properties")
      end

      it "has the correct content for use api option" do
        expect(response.body).to have_selector("h2.govuk-heading-m", text: I18n.t("data_access_options_page.use_api.title"))
        expect(response.body).to have_selector("p.govuk-body", text: I18n.t("data_access_options_page.use_api.description"))
        expect(response.body).to have_link(I18n.t("data_access_options_page.use_api.button_text"), href: "/use-api")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/data_access_options with different language parameters" do
    let(:response_welsh) { get "#{local_host}?lang=cy" }
    let(:response_english) { get "#{local_host}?lang=en" }

    it "shows Welsh: when lang=cy" do
      expect(response_welsh.body).to include("Sut hoffech chi gael mynediad i'r data?")
    end

    it "does not show Welsh: when lang=en" do
      expect(response_english.body).not_to include("Sut hoffech chi gael mynediad i'r data?")
    end
  end
end
