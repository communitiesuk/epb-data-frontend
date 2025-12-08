describe Gateway::NotifyGateway do
  subject(:gateway) { described_class.new(notify_client) }

  def notify_client
    Notifications::Client.new(ENV["NOTIFY_DATA_API_KEY"])
  end

  def template_id
    "f5d03031-b559-4264-8503-802ee0e78f4c"
  end

  let(:email_address) { "sender@something.com" }
  let(:personalisation) do
    {
      is_test: true,
      name: "John Smith",
      email: email_address,
      owner_or_occupier: "Owner",
      certificate_number: "1234-1234-1234-1234-1234",
      address_line1: "Flat 3",
      address_line2: "5 Bob Lane",
      town: "Testerton",
      postcode: "TE57 1NG",
    }
  end

  let(:send_email_api_response) do
    {
      "id": "201b576e-c09b-467b-9dfa-9c3b689ee730",

      "template": {
        "id": template_id,
        "version": 2,
        "uri": "https://api.notifications.service.gov.uk/v2/template/#{template_id}",
      },
    }
  end

  let(:check_status_api_response) do
    {
      "email_address": email_address,
      "type": "email",
      "status": "delivered",
    }
  end

  before do
    WebMock.stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
           .to_return(status: 200, body: send_email_api_response.to_json, headers: {})
  end

  describe "#send_email" do
    it "sends an email" do
      expect(gateway.send_email(template_id:, destination_email: email_address, **personalisation)).to eq("201b576e-c09b-467b-9dfa-9c3b689ee730")
      expect(WebMock).to have_requested(
        :post,
        "https://api.notifications.service.gov.uk/v2/notifications/email",
      ).with(
        body: '{"email_address":"sender@something.com","template_id":"f5d03031-b559-4264-8503-802ee0e78f4c","personalisation":{"is_test":true,"name":"John Smith","email":"sender@something.com","owner_or_occupier":"Owner","certificate_number":"1234-1234-1234-1234-1234","address_line1":"Flat 3","address_line2":"5 Bob Lane","town":"Testerton","postcode":"TE57 1NG"}}',
      )
    end
  end

  describe "#check_email_status" do
    before do
      WebMock.stub_request(:get, "https://api.notifications.service.gov.uk/v2/notifications/#{notification_id}")
             .to_return(status: 200, body: check_status_api_response.to_json, headers: {})
    end

    let(:notification_id) do
      gateway.send_email(template_id:, destination_email: email_address, **personalisation)
    end

    it "confirms delivery status of the email" do
      expect(gateway.check_email_status(notification_id)).to eq("delivered")
      expect(WebMock).to have_requested(
        :get,
        "https://api.notifications.service.gov.uk/v2/notifications/#{notification_id}",
      )
    end
  end
end
