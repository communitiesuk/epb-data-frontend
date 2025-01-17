describe "Acceptance::HealthCheck", type: :feature do
  include RSpecFrontendServiceMixin

  describe ".get get-energy-performance-data.local.gov.uk/healthcheck" do
    let(:response) do
      get "http://get-energy-performance-data.local.gov.uk/healthcheck"
    end

    it "returns status 200" do
      expect(response.status).to eq(200)
    end
  end
end
