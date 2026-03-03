require "aws-sdk-kms"
require "json"
require "base64"

describe Gateway::KmsGateway do
  subject(:gateway) { described_class.new(kms_client:) }

  let(:kms_client) do
    Aws::KMS::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

  let(:email) { "test@example.com" }
  let(:ciphertext_blob) { "encrypted-email-blob" }
  let(:encrypted_email) { Base64.strict_encode64(ciphertext_blob) }

  describe "#encrypt" do
    before do
      WebMock.stub_request(:post, "https://kms.eu-west-2.amazonaws.com/")
             .with(headers: { "X-Amz-Target" => "TrentService.Encrypt" })
             .to_return(
               status: 200,
               headers: { "Content-Type" => "application/x-amz-json-1.1" },
               body: {
                 "CiphertextBlob" => Base64.strict_encode64(ciphertext_blob),
                 "KeyId" => ENV["KMS_KEY_ID"],
               }.to_json,
             )
    end

    it "returns the encrypted email as a base64 encoded string" do
      expect(gateway.encrypt(email)).to eq(encrypted_email)
    end
  end

  describe "#decrypt" do
    before do
      WebMock.stub_request(:post, "https://kms.eu-west-2.amazonaws.com/")
             .with(headers: { "X-Amz-Target" => "TrentService.Decrypt" })
             .to_return(
               status: 200,
               headers: { "Content-Type" => "application/x-amz-json-1.1" },
               body: {
                 "Plaintext" => Base64.strict_encode64(email),
                 "KeyId" => ENV["KMS_KEY_ID"],
               }.to_json,
             )
    end

    it "returns the original email" do
      expect(gateway.decrypt(encrypted_email)).to eq(email)
    end
  end
end
