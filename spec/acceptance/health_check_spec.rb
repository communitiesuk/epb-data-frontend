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

  describe ".get /api-healthcheck" do
    let(:response) do
      get "/api-healthcheck"
    end

    context "with a successful data-warehouse api response" do
      it "returns status 200" do
        stub_request(:get, "http://epb-data-warehouse-api/healthcheck").to_return(status: 200)
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq("message" => "Connection to API: OK", "status" => 200)
      end
    end

    context "with an unsuccessful data-warehouse api response" do
      it "returns status 200" do
        stub_request(:get, "http://epb-data-warehouse-api/healthcheck").to_return(status: 500)
        expect(response.status).to eq(500)
        expect(JSON.parse(response.body)).to eq("message" => "Connection to API: OK", "status" => 500)
      end
    end

    context "with a timeout" do
      it "returns status 200" do
        stub_request(:get, "http://epb-data-warehouse-api/healthcheck").to_timeout
        expect(response.status).to eq(500)
        expect(JSON.parse(response.body)).to eq("details" => "execution expired", "error" => "Failed to reach API", "status" => 500)
      end
    end
  end
end
