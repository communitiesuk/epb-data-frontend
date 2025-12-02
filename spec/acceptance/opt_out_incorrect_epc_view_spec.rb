describe "Acceptance::OptOutIncorrectEpc", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/incorrect-epc" do
    let(:response) { get "#{base_url}/opt-out/incorrect-epc" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "contains the correct h1 header" do
      expect(response.body).to have_selector("h1", text: "What to do if your EPC is incorrect")
    end

    it "shows a back link and redirects to previous page" do
      expect(response.body).to have_link("Back", href: "/opt-out/reason")
    end
  end
end
