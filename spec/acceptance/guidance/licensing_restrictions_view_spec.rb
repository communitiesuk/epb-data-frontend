describe "Acceptance::LicensingRestrictions", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/licensing-restrictions" do
    let(:path) { "/guidance/licensing-restrictions" }
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
        expect(response.body).to have_css("h1", text: "Licensing restrictions")
      end

      it "has the correct content for non-address data section" do
        expect(response.body).to have_css("h2", text: "Non-Address Data")
        expect(response.body).to have_link("Open Government Licence v3.0", href: "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
      end

      it "has the correct content for survey and copyright section" do
        expect(response.body).to have_css("h2", text: "Ordnance Survey and Royal Mail Copyright and Database Right Notice")
        expect(response.body).to have_link("Further information about these exceptions can be found here", href: "https://www.gov.uk/guidance/exceptions-to-copyright")
        expect(response.body).to have_link("PricingLicensing@os.uk", href: "mailto:PricingLicensing@os.uk")
        expect(response.body).to have_link("address.management@royalmail.com", href: "mailto:address.management@royalmail.com")
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
