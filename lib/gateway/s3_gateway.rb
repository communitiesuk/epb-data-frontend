module Gateway
  class S3Gateway
    def initialize(signer_client)
      @signer_client = signer_client
    end

    def get_presigned_url(bucket:, file_name:, expires_in:)
      @signer_client.presigned_url(:get_object, bucket:, key: file_name, expires_in:)
    end
  end
end
