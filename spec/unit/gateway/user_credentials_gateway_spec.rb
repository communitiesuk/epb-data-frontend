require "aws-sdk-dynamodb"

describe Gateway::UserCredentialsGateway do
  subject(:gateway) { described_class.new(dynamo_db_client:, kms_gateway:) }

  let(:kms_gateway) { instance_double(Gateway::KmsGateway) }

  let(:dynamo_db_client) do
    Aws::DynamoDB::Client.new(
      stub_responses: true,
    )
  end

  let(:user_id) { "e40c46c3-4636-4a8a-abd7-be72e1a525f6" }
  let(:sub_id) { "mock-sub-id" }
  let(:email) { "test@email.com" }
  let(:bearer) { "abcdefghijklmnopqrstuv" }
  let(:table_name) { ENV.fetch("EPB_DATA_USER_CREDENTIAL_TABLE_NAME", "test_users_table") }
  let(:table_name_v2) { ENV.fetch("EPB_DATA_USER_CREDENTIAL_V2_TABLE_NAME", "test_users_table_v2") }

  describe "#insert_user" do
    context "when inserting a new user" do
      let(:encrypted_email) { "encrypted-email" }
      let(:frozen_time) { Time.utc(2025, 6, 25, 12, 32, 0) }

      before do
        Timecop.freeze(frozen_time)
        allow(SecureRandom).to receive_messages(
          uuid: user_id,
          alphanumeric: bearer,
        )
        allow(kms_gateway).to receive(:encrypt).with(email).and_return(encrypted_email)
      end

      after do
        Timecop.return
      end

      it "inserts the user into both tables and returns the userId" do
        expect(gateway.insert_user(one_login_sub: sub_id, email: email)).to eq(user_id)

        api_requests = dynamo_db_client.api_requests

        # Old table
        put_request = api_requests.find { |req| req[:operation_name] == :put_item }
        expect(put_request[:params][:table_name]).to eq(table_name)
        expect(put_request[:params][:item]).to include(
          "BearerToken" => { s: bearer },
          "CreatedAt" => { s: "2025-06-25 12:32:00 UTC" },
          "EmailAddress" => { s: "encrypted-email" },
          "OneLoginSub" => { s: sub_id },
          "OptOut" => { bool: false },
          "UserId" => { s: user_id },
        )

        # New table
        transact_request = api_requests.find { |req| req[:operation_name] == :transact_write_items }
        transact_items = transact_request[:params][:transact_items]

        expect(transact_items.count).to eq(2)

        # Profile Row
        expect(transact_items[0][:put][:table_name]).to eq(table_name_v2)
        expect(transact_items[0][:put][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "PROFILE" },
          "OneLoginSub" => { s: sub_id },
          "Attributes" => { m: {
            "CreatedAt" => { s: "2025-06-25 12:32:00 UTC" },
            "EmailAddress" => { s: "encrypted-email" },
            "OptOut" => { bool: false },
          } },
        })

        # Token Row
        expect(transact_items[1][:put][:table_name]).to eq(table_name_v2)
        expect(transact_items[1][:put][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "TOKEN##{user_id}" }, # Evaluates to user_id due to SecureRandom mock
          "BearerToken" => { s: bearer },
          "Attributes" => { m: {
            "CreatedAt" => { s: "2025-06-25 12:32:00 UTC" },
          } },
        })
      end

      it "encrypts the email using KmsGateway" do
        gateway.insert_user(one_login_sub: sub_id, email: email)
        expect(kms_gateway).to have_received(:encrypt).with(email).once
      end
    end
  end

  describe "#update_user_email" do
    let(:encrypted_email) { "encrypted-email" }

    before do
      allow(kms_gateway).to receive(:encrypt).with(email).and_return(encrypted_email)
    end

    context "when the user is missing the EmailAddress information" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "BearerToken" => bearer,
            "CreatedAt" => "2025-03-05T11:00:00Z",
          },
        })
      end

      it "updates the email in both the legacy and v2 user credentials tables" do
        gateway.update_user_email(user_id: user_id, email: email)

        put_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :put_item }

        expect(put_requests.count).to eq(2)

        # Old table
        expect(put_requests[0][:params][:table_name]).to eq(table_name)
        expect(put_requests[0][:params][:item]).to eq({
          "BearerToken" => { s: bearer },
          "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
          "EmailAddress" => { s: "encrypted-email" },
          "OneLoginSub" => { s: sub_id },
          "OptOut" => { bool: false },
          "UserId" => { s: user_id },
        })

        # New table
        expect(put_requests[1][:params][:table_name]).to eq(table_name_v2)
        expect(put_requests[1][:params][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "PROFILE" },
          "OneLoginSub" => { s: sub_id },
          "Attributes" => { m: {
            "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
            "EmailAddress" => { s: "encrypted-email" },
            "OptOut" => { bool: false },
          } },
        })
      end
    end

    context "when the user is missing the OptOut information" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "BearerToken" => bearer,
            "CreatedAt" => "2025-03-05T11:00:00Z",
            "EmailAddress" => encrypted_email,
          },
        })
      end

      it "updates the OptOut with the default in both user credentials tables" do
        gateway.update_user_email(user_id: user_id, email: email)

        put_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :put_item }

        expect(put_requests.count).to eq(2)

        # Old table
        expect(put_requests[0][:params][:table_name]).to eq(table_name)
        expect(put_requests[0][:params][:item]).to eq({
          "BearerToken" => { s: bearer },
          "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
          "EmailAddress" => { s: "encrypted-email" },
          "OneLoginSub" => { s: sub_id },
          "OptOut" => { bool: false },
          "UserId" => { s: user_id },
        })

        # New table
        expect(put_requests[1][:params][:table_name]).to eq(table_name_v2)
        expect(put_requests[1][:params][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "PROFILE" },
          "OneLoginSub" => { s: sub_id },
          "Attributes" => { m: {
            "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
            "EmailAddress" => { s: "encrypted-email" },
            "OptOut" => { bool: false },
          } },
        })
      end
    end
  end

  describe "#get_user" do
    context "when getting an existing user" do
      before do
        dynamo_db_client.stub_responses(:scan, {
          items: [
            {
              "UserId" => user_id,
              "OneLoginSub" => sub_id,
              "CreatedAt" => Time.now.to_s,
              "BearerToken" => "the-bearer-token",
            },
          ],
          count: 1,
        })
      end

      it "returns the UserId" do
        expect(gateway.get_user(sub_id)).to eq(user_id)

        scan_request = dynamo_db_client.api_requests.find { |req| req[:operation_name] == :scan }
        expect(scan_request[:params][:filter_expression]).to eq("OneLoginSub = :sub")
      end
    end

    context "when the user does not exist" do
      before do
        dynamo_db_client.stub_responses(:scan, {
          items: [],
          count: 0,
        })
      end

      it "returns nil" do
        expect(gateway.get_user("missing-sub-id")).to be_nil
      end
    end

    context "when getting an existing user and the results are paginated" do
      before do
        dynamo_db_client.stub_responses(:scan, [
          {
            items: [],
            count: 0,
            last_evaluated_key: { "UserId" => "some-other-user-id" },
          },
          {
            items: [
              {
                "UserId" => user_id,
                "OneLoginSub" => sub_id,
                "CreatedAt" => Time.now.to_s,
                "BearerToken" => bearer,
              },
            ],
            count: 1,
          },
        ])
      end

      it "returns the UserId from the second page" do
        expect(gateway.get_user(sub_id)).to eq(user_id)
      end
    end

    context "when the OneLoginSub is in multiple results" do
      before do
        dynamo_db_client.stub_responses(:scan, {
          items: [
            {
              "UserId" => user_id,
              "OneLoginSub" => sub_id,
              "CreatedAt" => Time.now.to_s,
              "BearerToken" => bearer,
            },
            {
              "UserId" => "another-user-id",
              "OneLoginSub" => sub_id,
              "CreatedAt" => Time.now.to_s,
              "BearerToken" => "another-bearer-token",
            },
          ],
          count: 2,
        })
      end

      it "returns the first UserId" do
        expect(gateway.get_user(sub_id)).to eq(user_id)
      end
    end
  end

  describe "#get_user_token" do
    context "when getting a token" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "CreatedAt" => Time.now.to_s,
            "BearerToken" => bearer,
          },
        })
      end

      it "returns the BearerToken" do
        expect(gateway.get_user_token(user_id)).to eq(bearer)
      end
    end

    context "when the token is missing" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: nil,
        })
      end

      it "raises Errors::BearerTokenMissing if the token is missing" do
        expect {
          gateway.get_user_token(user_id)
        }.to raise_error(Errors::BearerTokenMissing)
      end
    end
  end

  describe "#get_user_info" do
    context "when getting user info for an opted-out user" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "CreatedAt" => Time.now.to_s,
            "BearerToken" => bearer,
            "OptOut" => true,
          },
        })
      end

      it "returns the BearerToken and OptOut info" do
        expect(gateway.get_user_info(user_id)).to eq({ bearer_token: bearer, opt_out: true })
      end
    end

    context "when getting user info for a user missing opt-out value" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "CreatedAt" => Time.now.to_s,
            "BearerToken" => bearer,
          },
        })
      end

      it "returns the BearerToken and expected OptOut info" do
        expect(gateway.get_user_info(user_id)).to eq({ bearer_token: bearer, opt_out: false })
      end
    end

    context "when the user is missing" do
      before do
        dynamo_db_client.stub_responses(:get_item, { item: nil })
      end

      it "raises Errors::UserMissing" do
        expect {
          gateway.get_user_info(user_id)
        }.to raise_error(Errors::UserMissing)
      end
    end

    context "when the passed user_id is nil" do
      it "raises Errors::UserMissing" do
        expect {
          gateway.get_user_info(nil)
        }.to raise_error(Errors::UserMissing)
      end
    end
  end

  describe "#toggle_user_opt_out" do
    context "when toggling user opt-out value for an opted-out user" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "BearerToken" => bearer,
            "CreatedAt" => "2025-03-05T11:00:00Z",
            "EmailAddress" => "encrypted_email",
            "OptOut" => true,
          },
        })
      end

      it "updates the user opt-out value with false in both tables" do
        gateway.toggle_user_opt_out(user_id)

        put_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :put_item }

        expect(put_requests.count).to eq(2)

        # Old table
        expect(put_requests[0][:params][:table_name]).to eq(table_name)
        expect(put_requests[0][:params][:item]).to eq({
          "BearerToken" => { s: bearer },
          "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
          "EmailAddress" => { s: "encrypted_email" },
          "OneLoginSub" => { s: sub_id },
          "OptOut" => { bool: false },
          "UserId" => { s: user_id },
        })

        # New table
        expect(put_requests[1][:params][:table_name]).to eq(table_name_v2)
        expect(put_requests[1][:params][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "PROFILE" },
          "OneLoginSub" => { s: sub_id },
          "Attributes" => { m: {
            "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
            "EmailAddress" => { s: "encrypted_email" },
            "OptOut" => { bool: false },
          } },
        })
      end
    end

    context "when toggling user opt-out value for an opted-in user" do
      before do
        dynamo_db_client.stub_responses(:get_item, {
          item: {
            "UserId" => user_id,
            "OneLoginSub" => sub_id,
            "BearerToken" => bearer,
            "CreatedAt" => "2025-03-05T11:00:00Z",
            "EmailAddress" => "encrypted_email",
            "OptOut" => false,
          },
        })
      end

      it "updates the user opt-out value with true in both tables" do
        gateway.toggle_user_opt_out(user_id)

        put_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :put_item }

        expect(put_requests.count).to eq(2)

        # Old table
        expect(put_requests[0][:params][:table_name]).to eq(table_name)
        expect(put_requests[0][:params][:item]).to eq({
          "BearerToken" => { s: bearer },
          "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
          "EmailAddress" => { s: "encrypted_email" },
          "OneLoginSub" => { s: sub_id },
          "OptOut" => { bool: true },
          "UserId" => { s: user_id },
        })

        # New table
        expect(put_requests[1][:params][:table_name]).to eq(table_name_v2)
        expect(put_requests[1][:params][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "PROFILE" },
          "OneLoginSub" => { s: sub_id },
          "Attributes" => { m: {
            "CreatedAt" => { s: "2025-03-05T11:00:00Z" },
            "EmailAddress" => { s: "encrypted_email" },
            "OptOut" => { bool: true },
          } },
        })
      end
    end
  end

  describe "#delete_user" do
    before do
      dynamo_db_client.stub_responses(:query, {
        items: [
          { "UserId" => user_id, "Type" => "PROFILE" },
          { "UserId" => user_id, "Type" => "TOKEN#01234" },
          { "UserId" => user_id, "Type" => "TOKEN#56789" },
        ],
      })
    end

    it "deletes the user from the legacy and new credentials table" do
      gateway.delete_user(user_id)

      api_requests = dynamo_db_client.api_requests
      expect(api_requests.count).to eq(3)

      delete_request = api_requests[0]
      expect(delete_request[:params]).to eq({
        table_name: table_name,
        key: { "UserId" => { s: user_id } },
      })

      query_request = api_requests[1]
      expect(query_request[:params]).to eq({
        table_name: table_name_v2,
        key_condition_expression: "UserId = :user_id",
        expression_attribute_values: { ":user_id" => { s: user_id } },
      })

      transact_request = api_requests[2]
      expect(transact_request[:params][:transact_items]).to eq([
        {
          delete: {
            table_name: table_name_v2,
            key: { "UserId" => { s: user_id }, "Type" => { s: "PROFILE" } },
          },
        },
        {
          delete: {
            table_name: table_name_v2,
            key: { "UserId" => { s: user_id }, "Type" => { s: "TOKEN#01234" } },
          },
        },
        {
          delete: {
            table_name: table_name_v2,
            key: { "UserId" => { s: user_id }, "Type" => { s: "TOKEN#56789" } },
          },
        },
      ])
    end
  end
end
