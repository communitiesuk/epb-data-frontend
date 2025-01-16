# frozen_string_literal: true

require "net/http"

describe "Integration::Rackup" do
  process_id = nil

  before(:all) do
    process =
      IO.popen(
        [
          "rackup",
          "config_test.ru",
          "-q",
          "-o",
          "127.0.0.1",
          "-p",
          "9393",
          { err: %i[child out] },
        ],
      )
    process_id = process.pid

    process.readline # wait for initial output from server; ensures it's started
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  let(:http_request) do
    Net::HTTP.new("find-energy-performance-data.local.gov.uk", 9_393)
  end

  describe "GET /find-energy-performance-data.local.gov.uk" do
    before do
      stub_request(:get, "http://find-energy-performance-data.local.gov.uk:9393/")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "User-Agent" => "Ruby",
          },
        )
        .to_return(status: 200, body: "Get a new energy certificate", headers: {})
    end

    it "renders the find-energy-performance-data page" do
      req = Net::HTTP::Get.new("/")
      response = http_request.request(req)
      expect(response.code).to eq("200")
      expect(response.body).to include("Get a new energy certificate")
    end
  end
end
