module UseCase
  class SendDownloadRequest
    def initialize(sns_gateway:, topic_arn:)
      @sns_gateway = sns_gateway
      @topic_arn = topic_arn
    end

    def execute(property_type:, date_start:, date_end:, area_type:, area_value:, efficiency_ratings:, include_recommendations:, email_address:)
      raise Errors::InvalidPropertyType unless %w[domestic non_domestic dec].include? property_type

      download_request_message = {
        property_type: property_type,
        date_start: date_start,
        date_end: date_end,
        area: {
          "#{area_type}": area_value,
        },
        efficiency_ratings: efficiency_ratings,
        include_recommendations: include_recommendations,
        email_address: email_address,
      }
      @sns_gateway.send_message(@topic_arn, download_request_message)
    end
  end
end
