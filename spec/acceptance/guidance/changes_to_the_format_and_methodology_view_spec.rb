describe "Acceptance::ChangesToTheMethodAndMethodology", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/changes-to-the-format-and-methodology" do
    let(:path) { "/guidance/changes-to-the-format-and-methodology" }
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
        expect(response.body).to have_css("h1", text: "Changes to the format and methodology")
      end

      it "has the correct content for certificate changes section" do
        expect(response.body).to have_css("h2", text: "Certificate changes")
        expect(response.body).to have_css("p", text: "There have been multiple version changes which affect how domestic and non-domestic EPCs and DECs are formatted.")
        expect(response.body).to have_css("p", text: "You can find JSON Schema describing the different certificate versions on GitHub.")
        expect(response.body).to have_link("GitHub", href: "https://github.com/communitiesuk/epb-data-warehouse/tree/main/spec/fixtures/json_samples")
      end

      it "has the correct content for regulatory changes section" do
        expect(response.body).to have_css("h2", text: "Regulatory changes")
        expect(response.body).to have_css("li", text: "1 October 2008 – The requirement for DECs came into effect for buildings that are over 1,000 square meters, occupied by public authorities and frequently visited by the public.")
        expect(response.body).to have_css("li", text: "9 January 2013 – The floor area size threshold for DECs was lowered to buildings over 500 square meters.")
        expect(response.body).to have_css("li", text: "9 July 2015 – The floor area size threshold for DECs was lowered to buildings over 250 square meters.")
      end

      it "has the correct content for publishing changes section" do
        expect(response.body).to have_css("h2", text: "Publishing changes")
        expect(response.body).to have_css("li", text: "September 2020 – EPC data was migrated to a new register.")
        expect(response.body).to have_css("li", text: "November 2021 – UPRNs (Unique Property Reference Numbers) were added to the data.")
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
