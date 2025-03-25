require "aws-sdk-sns"

module Gateway
  class SnsGateway
    def initialize(sns_client = default_sns_client)
      @sns_client = sns_client
    end

    def send_message(topic_arn, message)
      @sns_client.publish(
        topic_arn: topic_arn,
        message: message.to_json,
        message_structure: "json",
      )
    rescue Aws::SNS::Errors::ServiceError => e
      raise e
    end

  private

    def default_sns_client
      Aws::SNS::Client.new(
        region: "eu-west-2",
        credentials: Aws::ECSCredentials.new,
      )
    end
  end
end
