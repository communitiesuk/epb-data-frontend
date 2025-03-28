describe Gateway::SnsGateway do
  subject(:gateway) { described_class.new(sns_client) }

  let(:sns_client) do
    Aws::SNS::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

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
            <MessageId>12345</MessageId>
          </PublishResult>
        </PublishResponse>
      XML
    end

    before do
      WebMock.stub_request(:post, url)
             .with(
               headers: headers,
               body: {
                 "Action" => "Publish",
                 "TopicArn" => topic_arn,
                 "Message" => message.to_json,
                 "Version" => "2010-03-31",
               },
             )
             .to_return(status: 200, body: mock_body_response, headers: { "Content-Type" => "text/xml" })
    end

    it "sends the message to the sns topic" do
      response = gateway.send_message(topic_arn, message)
      expect(response.message_id).to eq("12345")
    end
  end

  context "when an invalid topic arn is used" do
    let(:mock_body_response) do
      <<~XML
        <ErrorResponse xmlns="https://sns.amazonaws.com/doc/2010-03-31/">
          <Error>
            <Code>InvalidParameter</Code>
            <Message>Invalid topic ARN</Message>
          </Error>
        </ErrorResponse>
      XML
    end

    before do
      WebMock.stub_request(:post, url)
             .with(
               headers: headers,
               body: {
                 "Action" => "Publish",
                 "TopicArn" => topic_arn,
                 "Message" => message.to_json,
                 "Version" => "2010-03-31",
               },
             )
             .to_return(status: 400, body: mock_body_response, headers: { "Content-Type" => "text/xml" })
    end

    it "raises an error" do
      expect { gateway.send_message(topic_arn, message) }.to raise_error(Aws::SNS::Errors::InvalidParameter, "Invalid topic ARN")
    end
  end
end
