describe "Acceptance::OptOutAdvisedByThirdParty", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/advised-by-third-party" do
    let(:response) { get "#{base_url}/opt-out/advised-by-third-party" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "contains the correct h1 header" do
      expect(response.body).to have_selector("h1", text: "You do not need to opt out to access grant funding")
    end

    it "shows a back link and redirects to previous page" do
      expect(response.body).to have_link("Back", href: "/opt-out/reason")
    end
  end
end
