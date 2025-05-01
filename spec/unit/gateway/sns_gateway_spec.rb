describe Gateway::SnsGateway do
  subject(:gateway) { described_class.new }

  let(:topic_arn) { "arn:aws:sns:eu-west-2:123456789:MySNSTopic" }

  let(:url) { "https://sns.eu-west-2.amazonaws.com/" }

  let(:headers) do
    { "Content-Type" => "application/x-www-form-urlencoded; charset=utf-8" }
  end

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
    let(:mock_body_response) do
      <<~XML
        <PublishResponse xmlns="https://sns.amazonaws.com/doc/2010-03-31/">
          <PublishResult>
            <MessageId>messageId</MessageId>
          </PublishResult>
        </PublishResponse>
      XML
    end

    # before do
    #   WebMock.stub_request(:post, url)
    #          .with(
    #            headers: headers,
    #            body: {
    #              "Action" => "Publish",
    #              "TopicArn" => topic_arn,
    #              "Message" => message.to_json,
    #              "Version" => "2010-03-31",
    #            },
    #          )
    #          .to_return(status: 200, body: mock_body_response, headers: { "Content-Type" => "text/xml" })
    # end

    it "sends the message to the sns topic" do
      response = gateway.send_message(topic_arn, message)
      expect(response.message_id).to eq("messageId")
    end
  end
end
