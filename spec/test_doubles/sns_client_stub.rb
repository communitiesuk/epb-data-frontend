class SnsClientStub
  def self.fetch(message:)
    WebMock.stub_request(:post, "https://sns.eu-west-2.amazonaws.com/")
           .with(
             headers: { "Content-Type" => "application/x-www-form-urlencoded; charset=utf-8" },
             body: {
               "Action" => "Publish",
               "TopicArn" => "arn:aws:sns:us-east-1:123456789012:testTopic",
               "Message" => message.to_json,
               "Version" => "2010-03-31",
             },
           )
           .to_return(status: 200, body: mock_body_response, headers: { "Content-Type" => "text/xml" })
  end

  def self.mock_body_response
    <<~XML
      <PublishResponse xmlns="https://sns.amazonaws.com/doc/2010-03-31/">
        <PublishResult>
          <MessageId>messageId</MessageId>
        </PublishResult>
      </PublishResponse>
    XML
  end
end
