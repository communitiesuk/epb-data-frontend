describe Gateway::SnsGateway do
  subject(:gateway) { described_class.new }

  let(:topic_arn) { "arn:aws:sns:eu-west-2:123456789:MySNSTopic" }

  let(:message) do
    {
      "email_address" => "test@example.com",
      "property_type" => "domestic",
      "date_start" => "01-01-2021",
      "date_end" => "01-01-2022",
      "area" => {
        "councils" => %w[Aberdeen Angus],
      },
      "efficiency_ratings" => %w[A B C],
    }
  end

  context "when the message is successful" do
    it "sends the message to the sns topic" do
      response = gateway.send_message(topic_arn, message)
      expect(response.message_id).to eq("messageId")
    end
  end
end
