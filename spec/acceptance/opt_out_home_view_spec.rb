describe "Acceptance::OptOutHome", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out" do
    let(:response) { get "#{base_url}/opt-out" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end
  end
end
