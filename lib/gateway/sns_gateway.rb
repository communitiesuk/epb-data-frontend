require "aws-sdk-sns"

module Gateway
  class SnsGateway
    def initialize
      @sns_client = sns_client
    end

    def send_message(topic_arn, message)
      @sns_client.publish(
        topic_arn: topic_arn,
        message: message.to_json,
      )
    end

  private

    def sns_client
      case ENV["APP_ENV"]
      when "local", nil
        Aws::SNS::Client.new(stub_responses: true)
      else
        Aws::SNS::Client.new(region: "eu-west-2", credentials: Aws::ECSCredentials.new)
      end
    end
  end
end
