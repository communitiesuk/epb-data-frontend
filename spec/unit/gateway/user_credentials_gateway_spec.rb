require "aws-sdk-dynamodb"

describe Gateway::UserCredentialsGateway do
  subject(:gateway) { described_class.new(dynamo_db_client:) }

  let(:dynamo_db_client) do
    Aws::DynamoDB::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

  let(:user_id) do
    "e40c46c3-4636-4a8a-abd7-be72e1a525f6"
  end

  describe "#insert_user" do
    context "when inserting a new user" do
      let(:expected_put_item_body) do
        {
          "Item": {
            "UserId": {
              "S": user_id,
            },
            "CreatedAt": {
              "S": Time.utc(2025, 6, 25, 12, 32),
            },
            "BearerToken": {
              "S": "D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r",
            },
            "OneLoginSub": {
              "S": "mock-sub-id",
            },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      before do
        Timecop.freeze(Time.utc(2025, 6, 25, 12, 32, 0))
        allow(SecureRandom).to receive_messages(
          uuid: user_id,
          alphanumeric: "D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r",
        )
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
          .with(body: expected_put_item_body,
                headers: {
                  "X-Amz-Target" => "DynamoDB_20120810.PutItem",
                })
          .to_return(status: 200, body: "{}")
      end

      after do
        Timecop.return
      end

      it "returns the new UserId" do
        expect(gateway.insert_user("mock-sub-id")).to eq(user_id)
      end
    end
  end

  describe "#get_user" do
    context "when getting an existing user" do
      let(:expected_query_body) do
        {
          "FilterExpression":
            "OneLoginSub = :sub",
          "ExpressionAttributeValues": {
            ":sub": { "S": "mock-sub-id" },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      let(:query_response) do
        {
          "Items" => [
            {
              "UserId" => { "S" => user_id },
              "OneLoginSub" => { "S" => "mock-sub-id" },
              "CreatedAt" => { "S" => Time.now.to_s },
              "BearerToken" => { "S" => "the-bearer-token" },
            },
          ],
          "Count" => 1,
        }.to_json
      end

      before do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
               .with(body: expected_query_body,
                     headers: {
                       "X-Amz-Target" => "DynamoDB_20120810.Scan",
                     })
               .to_return(status: 200, body: query_response)
      end

      it "returns the UserId" do
        expect(gateway.get_user("mock-sub-id")).to eq(user_id)
      end
    end

    context "when the user does not exist" do
      let(:expected_query_body) do
        {
          "FilterExpression":
            "OneLoginSub = :sub",
          "ExpressionAttributeValues": {
            ":sub": { "S": "missing-sub-id" },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      let(:query_response) do
        {
          "Items" => [],
          "Count" => 0,
        }.to_json
      end

      before do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
               .with(body: expected_query_body,
                     headers: {
                       "X-Amz-Target" => "DynamoDB_20120810.Scan",
                     })
               .to_return(status: 200, body: query_response)
      end

      it "returns the UserId" do
        expect(gateway.get_user("missing-sub-id")).to be_nil
      end
    end
  end
end
