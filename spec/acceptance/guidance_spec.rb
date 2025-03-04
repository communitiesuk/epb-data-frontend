describe "Acceptance::ServiceStartPage", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/guidance"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/guidance" do
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
        expect(response.body).to have_css("h1", text: "Guidance")
      end

      it "has the correct content under the title" do
        expect(response.body).to have_css("p", text: "You can use these resources to help you understand and use energy certificate data.")
      end

      it "has the correct content for understanding the data" do
        expect(response.body).to have_css("h2", text: "Understanding the data")
        expect(response.body).to have_css("p", text: "Information on how the data is formatted and produced.")
        expect(response.body).to have_link("What information the data contains", href: "/data-information")
        expect(response.body).to have_link("How the data is produced and released", href: "/how-data-is-produced-released")
        expect(response.body).to have_link("Changes to the format and methodology", href: "/changes-to-format-methodology")
        expect(response.body).to have_link("Data limitations and quality", href: "/data-limitations-quality")
      end

      it "has the correct content for publishing and usage restrictions" do
        expect(response.body).to have_css("h2", text: "Publishing and usage restrictions")
        expect(response.body).to have_css("p", text: "Information on the restrictions that affect how the data is published and how you can use it.")
        expect(response.body).to have_link("Licensing restrictions", href: "/licensing-restrictions")
        expect(response.body).to have_link("Data protection", href: "/data-protection")
      end

      it "has the correct content for developer apis" do
        expect(response.body).to have_css("h2", text: "Developer APIs")
        expect(response.body).to have_css("p", text: "Information on using a developer API.")
        expect(response.body).to have_link("API guidance", href: "/api-guidance")
        expect(response.body).to have_link("API technical documentation", href: "/api-technical-documentation")
      end

      it "has the Get Help section" do
        expect(response.body).to have_css("h2", text: "Get help")
      end

      it "has the correct MHCLG contact email" do
        expect(response.body).to have_content("mhclg.digital-services@communities.gov.uk")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end
end
