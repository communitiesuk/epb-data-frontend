describe "Acceptance::DataDictionary", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/data-dictionary" do
    let(:path) { "/guidance/data-dictionary" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Data dictionary")
      end

      it "has the correct content under the title" do
        expect(response.body).to have_css("p", text: "The data dictionary provides an explanation for every variable included in the dataset, as well as information on the data source and caveats.")
        expect(response.body).to have_css("p", text: "The data dictionary is only available for Domestic EPC data.")
      end

      it "has the correct content for documents section" do
        expect(response.body).to have_css("h2", text: "Documents")
        expect(response.body).to have_link("Domestic EPC Data Dictionary", href: "/download/data-dictionary?property_type=domestic")
        expect(response.body).to have_link("Non-Domestic EPC Data Dictionary", href: "/download/data-dictionary?property_type=non_domestic")
        expect(response.body).to have_link("Display EPC Data Dictionary", href: "/download/data-dictionary?property_type=display")
      end

      it "renders the csv icon" do
        expect(response.body).to have_css("svg")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end
end
