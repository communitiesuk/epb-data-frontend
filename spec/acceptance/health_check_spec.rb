describe "Acceptance::HealthCheck", type: :feature do
  include RSpecFrontendServiceMixin

  describe ".get find-energy-performance-data.local.gov.uk/healthcheck" do
    let(:response) do
      get "http://find-energy-performance-data.local.gov.uk/healthcheck"
    end

    it "returns status 200" do
      expect(response.status).to eq(200)
    end
  end
end
