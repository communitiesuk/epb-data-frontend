describe "Acceptance::OptOutHome", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out" do
    let(:response) { get "#{base_url}/opt-out" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "displays the title as expected" do
      expect(response.body).to have_css("h1", text: "Opting out an EPC")
    end

    it "has a link for viewing the guidance page" do
      expect(response.body).to have_link("View the guidance", href: "https://www.gov.uk/guidance/energy-performance-certificates-opt-out-of-public-disclosure")
    end

    it "has a link to continue to opt_out reason page" do
      expect(response.body).to have_link("Continue", href: "/opt-out/reason")
    end
  end
end
