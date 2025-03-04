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
        expect(response.body).to have_link("Start now", href: "/data_access_options")
      end

      it "has the correct link to Scottish EPC Register, guidance page and EPC Register" do
        expect(response.body).to have_link("visit the Scottish EPC Register", href: "https://www.scottishepcregister.org.uk/")
        expect(response.body).to have_link("visit the EPC Register", href: "https://www.gov.uk/find-energy-certificate")
        expect(response.body).to have_link("Visit the guidance page", href: "/guidance")
      end

      it "has the Get Help section" do
        expect(response.body).to have_css("h2", text: "Get help")
      end

      it "has the correct MHCLG contact email" do
        expect(response.body).to have_content("mhclg.digital-services@communities.gov.uk")
      end
    end
  end
end
