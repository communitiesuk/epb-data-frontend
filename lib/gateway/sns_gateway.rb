require "aws-sdk-sns"

module Gateway
  class SnsGateway
    def initialize(sns_client)
      @sns_client = sns_client
    end

    def send_message(topic_arn, message)
      @sns_client.publish(
        topic_arn: topic_arn,
        message: message.to_json,
      )
    rescue Aws::SNS::Errors::ServiceError => e
      raise e
    end
  end
end
