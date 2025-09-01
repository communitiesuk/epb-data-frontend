describe "Acceptance::ApiGuidance", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/api/api-guidance"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/api/api-guidance" do
    context "when the page is rendered" do
      it "returns a 200 status" do
        expect(response.status).to eq(200)
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Using energy certificate data APIs")
      end

      it "has the correct subheading" do
        expect(response.body).to have_css("p", text: "Information to help developers use energy certificate data APIs")
      end

      it "has the Authentication section with the correct links" do
        expect(response.body).to have_css("h2", text: "Authentication")
        expect(response.body).to have_link("sign in", href: "/login?referer=api/api-guidance")
        expect(response.body).to have_link("create an account", href: "/login?referer=api/api-guidance")
      end

      it "has the Technical documentation section with the correct link" do
        expect(response.body).to have_css("h2", text: "Technical documentation")
        expect(response.body).to have_link("View technical documentation", href: "https://api-docs.epcregisters.net/")
      end

      it "has the Get Help section" do
        expect(response.body).to have_css("h2", text: "Get help")
      end
    end
  end
end
