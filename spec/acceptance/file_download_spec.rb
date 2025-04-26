describe "Acceptance::FileDownload", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/download"
  end

  describe "get .get-energy-certificate-data.epb-frontend/download" do
    let(:file_name) do
      "output/323eee63-6c56-4e77-9e36-7699f4cb240.csv"
    end

    let(:response) do
      get "#{local_host}?file=#{file_name}"
    end

    it "returns status the redirect status" do
      expect(response.status).to eq(302)
    end

    it "the response location will be to the pre-signed url" do
      expect(response.headers["location"]).to include("https://user-data.s3.us-stubbed-1.amazonaws.com/#{file_name}?X-Amz-Algorithm=AWS4-HMAC")
    end
  end
end
