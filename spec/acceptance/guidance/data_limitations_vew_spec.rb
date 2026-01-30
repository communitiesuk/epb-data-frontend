describe "Acceptance::DataLimitations", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/data-limitations" do
    let(:path) { "/guidance/data-limitations" }
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
        expect(response.body).to have_css("h1", text: "Data limitations and exclusions")
      end

      it "has the correct section titles" do
        expect(response.body).to have_css("h2", text: "Representativeness")
        expect(response.body).to have_css("h2", text: "Date availability")
        expect(response.body).to have_css("h2", text: "Data quality")
        expect(response.body).to have_css("h2", text: "Boundary changes")
        expect(response.body).to have_css("h2", text: "What data is excluded")
      end

      it "displays the anomalies table with ten rows" do
        expect(response.body).to have_css("table.govuk-table")
        expect(response.body).to have_css("tbody.govuk-table__body tr", count: 10)
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
