# frozen_string_literal: true

require "aws-sdk-sns"

class Container
  def initialize
    aws_credentials = ENV["STAGE"] == "test" ? Aws::Credentials.new(ENV["AWS_TEST_ACCESS_ID"], ENV["AWS_TEST_ACCESS_KEY"]) : Aws::ECSCredentials.new

    aws_sns_client = Aws::SNS::Client.new(
      region: "eu-west-2",
      credentials: aws_credentials,
    )
    sns_gateway = Gateway::SnsGateway.new(aws_sns_client)
    send_download_request_use_case = UseCase::SendDownloadRequest.new(sns_gateway:)
    @objects = {
      send_download_request_use_case:,
    }
  end

  def get_object(key)
    @objects[key]
  end
end
