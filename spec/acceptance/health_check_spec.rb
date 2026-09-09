describe "Acceptance::HealthCheck", type: :feature do
  include RSpecFrontendServiceMixin

  describe ".get /healthcheck" do
    let(:response) do
      get "/healthcheck"
    end

    it "returns status 200" do
      expect(response.status).to eq(200)
    end
  end
end
