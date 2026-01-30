describe "Acceptance::LinkingCertificatesToRecommendations", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/linking-certificates-to-recommendations" do
    let(:path) { "/guidance/linking-certificates-to-recommendations" }
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
        expect(response.body).to have_css("h1", text: "Linking certificates to recommendations")
      end

      it "has the correct content under the title" do
        expect(response.body).to have_css("p", text: "The method to link certificates to their recommendations varies depending on how the data is accessed:")
      end

      it "has the correct content for CSV download section" do
        expect(response.body).to have_css("p", text: "For domestic EPC and non-domestic EPC data, the certificate numbers can be used to identify certificates and to link them with their recommendations.")
      end

      it "has the correct content for API section" do
        expect(response.body).to have_css("p", text: "For domestic EPC data, the recommendation reports are included in the EPCs.")
        expect(response.body).to have_css("p", text: "For non-domestic EPC data, the certificate numbers can be used to fetch the recommendation reports.")
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
