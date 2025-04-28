require "aws-sdk-s3"

describe Gateway::S3Gateway do
  subject(:gateway) { described_class.new }

  describe "#get_presigned_url" do
    let(:signed_url) do
      gateway.get_presigned_url(bucket: "user-data", file_name: "folder/test.csv", expires_in: 60)
    end

    it "returns a url of the bucket path, folder and file name" do
      expect(signed_url).to include("https://user-data.s3.us-stubbed-1.amazonaws.com/folder/test.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256")
    end

    it "the url has the correct expiry time" do
      expect(signed_url).to include("Expires=60")
    end
  end
end
