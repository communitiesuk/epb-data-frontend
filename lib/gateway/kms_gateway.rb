require "aws-sdk-kms"

module Gateway
  class KmsGateway
    def initialize(kms_client: nil)
      @kms_client = kms_client || get_kms_client
      @key_id = ENV["KMS_KEY_ID"]
    end

    def encrypt(email)
      response = @kms_client.encrypt(
        key_id: @key_id,
        plaintext: email,
      )
      Base64.strict_encode64(response.ciphertext_blob)
    end

    def decrypt(ciphertext)
      response = @kms_client.decrypt(
        key_id: @key_id,
        ciphertext_blob: Base64.strict_decode64(ciphertext),
      )
      response.plaintext
    end

  private

    def get_kms_client
      case ENV["APP_ENV"]
      when "production"
        Aws::KMS::Client.new(region: "eu-west-2", credentials: Aws::ECSCredentials.new)
      else
        Aws::KMS::Client.new(stub_responses: true)
      end
    end
  end
end
