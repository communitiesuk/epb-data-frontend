# frozen_string_literal: true

require "aws-sdk-sns"
require "aws-sdk-s3"

class Container
  def initialize
    count_api_client = Auth::HttpClient.new ENV["EPB_AUTH_CLIENT_ID"],
                                            ENV["EPB_AUTH_CLIENT_SECRET"],
                                            ENV["EPB_AUTH_SERVER"],
                                            ENV["EPB_DATA_WAREHOUSE_API_URL"],
                                            OAuth2::Client,
                                            faraday_connection_opts: { request: { timeout: 20 } }

    sns_gateway = Gateway::SnsGateway.new
    send_download_request_use_case = UseCase::SendDownloadRequest.new(sns_gateway:, topic_arn: ENV["SEND_DOWNLOAD_TOPIC_ARN"])
    certificate_count_gateway = Gateway::CertificateCountGateway.new(count_api_client)
    get_download_size_use_case = UseCase::GetDownloadSize.new(certificate_count_gateway:)
    get_presigned_url_use_case = UseCase::GetPresignedUrl.new(gateway: Gateway::S3Gateway.new, bucket_name: ENV["AWS_S3_USER_DATA_BUCKET_NAME"])
    sign_onelogin_request_use_case = UseCase::SignOneloginRequest.new
    onelogin_token_gateway = Gateway::OneloginTokenGateway.new
    request_onelogin_token_use_case = UseCase::RequestOneloginToken.new(onelogin_token_gateway:)
    @objects = {
      send_download_request_use_case:,
      get_download_size_use_case:,
      get_presigned_url_use_case:,
      sign_onelogin_request_use_case:,
      request_onelogin_token_use_case:,
    }
  end

  def get_object(key)
    @objects[key]
  end
end
