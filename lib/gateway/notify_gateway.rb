require "notifications/client"

module Gateway
  class NotifyGateway
    def initialize(notify_client)
      @client = notify_client
    end

    def send_email(template_id:, destination_email:, email:, is_test:, name:, owner_or_occupier:, certificate_number:, address_line1:, address_line2:, town:, postcode:)
      response = @client.send_email(
        email_address: destination_email,
        template_id:,
        personalisation: {
          is_test:,
          name:,
          email:,
          owner_or_occupier:,
          certificate_number:,
          address_line1:,
          address_line2:,
          town:,
          postcode:,
        },
      )

      response.id
    rescue Notifications::Client::BadRequestError, Notifications::Client::AuthError, Notifications::Client::RateLimitError => e
      raise Errors::NotifySendEmailError, e.message
    rescue Notifications::Client::ServerError
      raise Errors::NotifyServerError
    end

    def check_email_status(notification_id)
      @client.get_notification(notification_id).status
    end
  end
end
