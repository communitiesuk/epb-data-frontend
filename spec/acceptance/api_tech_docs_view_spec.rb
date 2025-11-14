describe "Acceptance::ApiTechnicalDocumentation", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/api-technical-documentation" do
    let(:path) { "/api-technical-documentation" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Energy certificate data API documentation")
      end

      it "has the navigation links" do
        expect(response.body).to have_link("Overview", href: "#overview")
        expect(response.body).to have_link("Making a request", href: "#making-a-request")
        expect(response.body).to have_link("Headers", href: "#headers")
      end
    end
  end
end
