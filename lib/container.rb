# frozen_string_literal: true

require "aws-sdk-sns"

class Container
  def initialize
    sns_gateway = Gateway::SnsGateway.new(sns_client)
    send_download_request_use_case = UseCase::SendDownloadRequest.new(sns_gateway:)
    certificate_count_gateway = Gateway::CertificateCountGateway.new(api_client:)
    get_download_size_use_case = UseCase::GetDownloadSize.new(certificate_count_gateway:)
    @objects = {
      internal_api_client: api_client,
      send_download_request_use_case:,
      get_download_size_use_case:,
    }
  end

  def get_object(key)
    @objects[key]
  end

private

  def api_client
    Auth::HttpClient.new ENV["EPB_AUTH_CLIENT_ID"],
                         ENV["EPB_AUTH_CLIENT_SECRET"],
                         ENV["EPB_AUTH_SERVER"],
                         ENV["EPB_DATA_WAREHOUSE_API_URL"],
                         OAuth2::Client,
                         faraday_connection_opts: { request: { timeout: 8 } }
  end

  def sns_client
    aws_credentials = ENV["STAGE"] == "test" ? Aws::Credentials.new(ENV["AWS_TEST_ACCESS_ID"], ENV["AWS_TEST_ACCESS_KEY"]) : Aws::ECSCredentials.new

    Aws::SNS::Client.new(
      region: "eu-west-2",
      credentials: aws_credentials,
    )
  end
end
