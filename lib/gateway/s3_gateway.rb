require "aws-sdk-s3"

module Gateway
  class S3Gateway
    def initialize
      @signer_client = s3_client
    end

    def get_presigned_url(bucket:, file_name:, expires_in:)
      @signer_client.presigned_url(:get_object, bucket:, key: file_name, expires_in:)
    end

  private

    def s3_client
      client = case ENV["APP_ENV"]
               when "local", nil
                 Aws::S3::Client.new(stub_responses: true)
               else
                 Aws::S3::Client.new(region: "eu-west-2", credentials: Aws::ECSCredentials.new)
               end
      Aws::S3::Presigner.new(client:)
    end
  end
end
