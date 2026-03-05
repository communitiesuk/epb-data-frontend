require "aws-sdk-dynamodb"

describe Gateway::UserCredentialsGateway do
  subject(:gateway) { described_class.new(dynamo_db_client:, kms_gateway:) }

  let(:kms_gateway) { instance_double(Gateway::KmsGateway) }

  let(:dynamo_db_client) do
    Aws::DynamoDB::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

  let(:user_id) do
    "e40c46c3-4636-4a8a-abd7-be72e1a525f6"
  end

  let(:sub_id) do
    "mock-sub-id"
  end

  let(:email) do
    "test@email.com"
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
              "S": sub_id,
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
        expect(gateway.insert_user(one_login_sub: sub_id, email: email)).to eq(user_id)
      end

      context "when the 'epb-frontend-data-allow-email-encryption' toggle is disabled" do
        before do
          allow(kms_gateway).to receive(:encrypt)
          gateway.insert_user(one_login_sub: sub_id, email: email)
        end

        it "does not attempt to encrypt the email" do
          expect(kms_gateway).not_to have_received(:encrypt)
        end
      end

      context "when the 'epb-frontend-data-allow-email-encryption' toggle is enabled" do
        let(:encrypted_email) { "encrypted-email" }
        let(:expected_put_item_body_with_email) do
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
                "S": sub_id,
              },
              "EmailAddress": {
                "S": encrypted_email,
              },
            },
            "TableName": "test_users_table",
          }.to_json
        end

        before do
          Helper::Toggles.set_feature("epb-frontend-data-allow-email-encryption", true)
          allow(kms_gateway).to receive(:encrypt).with(email).and_return(encrypted_email)

          Timecop.freeze(Time.utc(2025, 6, 25, 12, 32, 0))

          allow(SecureRandom).to receive_messages(
            uuid: user_id,
            alphanumeric: "D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r",
          )
          WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
                 .with(body: expected_put_item_body_with_email,
                       headers: {
                         "X-Amz-Target" => "DynamoDB_20120810.PutItem",
                       })
                 .to_return(status: 200, body: "{}")
        end

        after do
          Timecop.return
          Helper::Toggles.set_feature("epb-frontend-data-allow-email-encryption", false)
        end

        it "encrypts the email using KmsGateway" do
          gateway.insert_user(one_login_sub: sub_id, email: email)
          expect(kms_gateway).to have_received(:encrypt).with(email).once
        end

        it "inserts the user and returns the userId" do
          expect(gateway.insert_user(one_login_sub: sub_id, email: email)).to eq(user_id)
        end
      end
    end
  end

  describe "#update_user" do
    before do
      WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
       .with(headers: { "X-Amz-Target" => "DynamoDB_20120810.GetItem" })
       .to_return(
         status: 200,
         body: {
           "Item" => {
             "UserId" => { "S" => user_id },
             "OneLoginSub" => { "S" => "sub_abcdef123" },
             "BearerToken" => { "S" => "token123" },
             "CreatedAt" => { "S" => "2025-03-05T11:00:00Z" },
           },
         }.to_json,
         headers: { "Content-Type" => "application/x-amz-json-1.0" },
       )
      WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
             .with(headers: { "X-Amz-Target" => "DynamoDB_20120810.PutItem" })
             .to_return(status: 200, body: "", headers: {})
    end

    context "when the 'epb-frontend-data-allow-email-encryption' toggle is enabled" do
      let(:encrypted_email) { "encrypted-email" }

      before do
        allow(kms_gateway).to receive(:encrypt).with(email).and_return(encrypted_email)
        Helper::Toggles.set_feature("epb-frontend-data-allow-email-encryption", true)
      end

      after do
        Helper::Toggles.set_feature("epb-frontend-data-allow-email-encryption", false)
      end

      it "updates the email into the user credentials table" do
        expected_body = {
          "Item" => {
            "UserId" => { "S" => user_id },
            "OneLoginSub" => { "S" => "sub_abcdef123" },
            "BearerToken" => { "S" => "token123" },
            "CreatedAt" => { "S" => "2025-03-05T11:00:00Z" },
            "EmailAddress" => { "S" => encrypted_email },
          },
          "TableName" => ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"] || "test_users_table",
        }.to_json

        gateway.update_user_email(user_id:, email:)

        expect(WebMock).to have_requested(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
          .with(
            body: expected_body,
            headers: { "X-Amz-Target" => "DynamoDB_20120810.PutItem" },
          )
      end
    end

    context "when the 'epb-frontend-data-allow-email-encryption' toggle is disabled" do
      let(:encrypted_email) { "encrypted-email" }

      before do
        allow(kms_gateway).to receive(:encrypt).with(email).and_return(encrypted_email)
        Helper::Toggles.set_feature("epb-frontend-data-allow-email-encryption", false)
      end

      it "updates the email into the user credentials table" do
        expected_body = {
          "Item" => {
            "UserId" => { "S" => user_id },
            "OneLoginSub" => { "S" => "sub_abcdef123" },
            "BearerToken" => { "S" => "token123" },
            "CreatedAt" => { "S" => "2025-03-05T11:00:00Z" },
          },
          "TableName" => ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"] || "test_users_table",
        }.to_json

        gateway.update_user_email(user_id:, email:)

        expect(WebMock).to have_requested(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
          .with(body: expected_body)
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
            ":sub": { "S": sub_id },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      let(:query_response) do
        {
          "Items" => [
            {
              "UserId" => { "S" => user_id },
              "OneLoginSub" => { "S" => sub_id },
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
        expect(gateway.get_user(sub_id)).to eq(user_id)
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

  describe "#get_user_token" do
    let(:expected_query_body) do
      {
        "Key": {
          "UserId": { "S": user_id },
        },
        "TableName": "test_users_table",
      }.to_json
    end

    context "when getting a token" do
      let(:query_response) do
        {
          "Item" => {
            "UserId" => { "S" => user_id },
            "OneLoginSub" => { "S" => sub_id },
            "CreatedAt" => { "S" => Time.now.to_s },
            "BearerToken" => { "S" => "the-bearer-token" },
          },
        }.to_json
      end

      before do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
               .with(body: expected_query_body,
                     headers: {
                       "X-Amz-Target" => "DynamoDB_20120810.GetItem",
                     })
               .to_return(status: 200, body: query_response)
      end

      it "returns the BearerToken" do
        expect(gateway.get_user_token(user_id)).to eq("the-bearer-token")
      end
    end

    context "when the token is missing" do
      it "raises Errors::BearerTokenMissing if the token is missing" do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
               .with(body: expected_query_body,
                     headers: {
                       "X-Amz-Target" => "DynamoDB_20120810.GetItem",
                     })
               .to_return(status: 200, body: {}.to_json)

        expect {
          gateway.get_user_token(user_id)
        }.to raise_error(Errors::BearerTokenMissing)
      end
    end
  end
end
