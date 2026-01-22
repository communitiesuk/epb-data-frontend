describe "Acceptance::ServiceStartPage", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/" do
    context "when the start page is rendered" do
      it "the title to be correct" do
        expect(response.body).to have_css("h1", text: "Get energy certificate data")
      end

      it "has the correct Start now button" do
        expect(response.body).to have_link("Start now", href: "/data-access-options")
      end

      it "has the correct link to Scottish EPB Register, guidance page and EPB Register" do
        expect(response.body).to have_link("visit the Scottish Energy Performance Certificate Register", href: "https://www.scottishepcregister.org.uk/")
        expect(response.body).to have_link("visit the Energy Performance Certificate Register", href: "https://www.gov.uk/find-energy-certificate")
        expect(response.body).to have_link("Visit the guidance page", href: "/guidance")
      end

      it "has the how you can use and what will you need section" do
        expect(response.body).to have_css("h2", text: "How you can use this service")
        expect(response.body).to have_css("h2", text: "What you will need")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "has the correct MHCLG contact email" do
        expect(response.body).to have_content("mhclg.digital-services@communities.gov.uk")
      end
    end
  end
end
