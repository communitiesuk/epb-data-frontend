require "aws-sdk-dynamodb"

module Gateway
  class UserCredentialsGateway
    def initialize(kms_gateway:, dynamo_db_client: nil)
      @kms_gateway = kms_gateway
      table_name = ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"]
      table_name_v2 = ENV["EPB_DATA_USER_CREDENTIAL_V2_TABLE_NAME"]
      client = dynamo_db_client || get_dynamo_db_client
      dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = dynamo_resource.table(table_name)
      @table_v2 = dynamo_resource.table(table_name_v2)
    end

    def insert_user(one_login_sub:, email:)
      # Legacy insert
      user_id = SecureRandom.uuid
      encrypted_email = @kms_gateway.encrypt(email)
      bearer_token = SecureRandom.alphanumeric(22)
      created_at = Time.now.to_s

      new_user = {
        "UserId" => user_id,
        "CreatedAt" => created_at,
        "BearerToken" => bearer_token,
        "OneLoginSub" => one_login_sub,
        "EmailAddress" => encrypted_email,
        "OptOut" => false,
      }

      @table.put_item(item: new_user)

      # New table insert
      profile_row = {
        "UserId" => user_id,
        "Type" => "PROFILE",
        "GSI1_PK" => "ONELOGIN##{one_login_sub}",
        "Attributes" => {
          "CreatedAt" => created_at,
          "EmailAddress" => encrypted_email,
          "OptOut" => false,
        },
      }

      bearer_row = {
        "UserId" => user_id,
        "Type" => "TOKEN##{bearer_token}",
        "GSI1_PK" => "TOKEN##{bearer_token}",
        "Attributes" => {
          "CreatedAt" => created_at,
        },
      }

      transact_items = [
        {
          put: {
            table_name: @table_v2.name,
            item: profile_row,
          },
        },
        {
          put: {
            table_name: @table_v2.name,
            item: bearer_row,
          },
        },
      ]

      @table_v2.client.transact_write_items(
        transact_items:,
      )
      user_id
    end

    def update_user_email(user_id:, email:)
      user = @table_v2.get_item(key: { "UserId" => user_id, "Type" => "PROFILE" }).item
      legacy_user = @table.get_item(key: { "UserId" => user_id }).item

      raise Errors::UserMissing unless user && legacy_user

      encrypted_email = @kms_gateway.encrypt(email)
      user["Attributes"].merge!("EmailAddress" => encrypted_email)
      user["Attributes"].merge!("OptOut" => false) if user["Attributes"].fetch("OptOut", nil).nil?

      @table.put_item(
        item: {
          "UserId" => user_id,
          "CreatedAt" => user["Attributes"]["CreatedAt"],
          "BearerToken" => legacy_user["BearerToken"],
          "OneLoginSub" => legacy_user["OneLoginSub"],
          "EmailAddress" => user["Attributes"]["EmailAddress"],
          "OptOut" => user["Attributes"]["OptOut"],
        },
      )

      @table_v2.put_item(
        item: user,
      )
    end

    def get_user(one_login_sub)
      params = {
        index_name: "GSI1_PK_Index",
        key_condition_expression: "GSI1_PK = :sub",
        expression_attribute_values: { ":sub" => "ONELOGIN##{one_login_sub}" },
      }
      response = @table_v2.query(
        **params,
      )
      response.items.count.zero? ? nil : response.items.first["UserId"]
    end

    def get_user_token(user_id)
      response = @table_v2.query(
        key_condition_expression: "UserId = :pk AND begins_with(#t, :sk)",
        expression_attribute_names: {
          "#t" => "Type", # Alias for the reserved word
        },
        expression_attribute_values: {
          ":pk" => user_id,
          ":sk" => "TOKEN",
        },
      )
      raise Errors::BearerTokenMissing unless response.items.any?

      response.items.first["Type"].delete_prefix("TOKEN#")
    end

    def get_user_info(user_id)
      raise Errors::UserMissing if user_id.nil?

      response = @table_v2.query(
        key_condition_expression: "UserId = :pk",
        expression_attribute_values: {
          ":pk" => user_id,
        },
      )
      profile_item = response.items.find { |item| item["Type"] == "PROFILE" }
      raise Errors::UserMissing unless profile_item

      token_item = response.items.find { |item| item["Type"]&.start_with?("TOKEN") }
      raise Errors::BearerTokenMissing unless token_item

      {
        bearer_token: token_item["Type"].delete_prefix("TOKEN#"),
        opt_out: profile_item["Attributes"]["OptOut"] || false,
      }
    end

    def toggle_user_opt_out(user_id)
      user = @table_v2.get_item(key: { "UserId" => user_id, "Type" => "PROFILE" }).item
      legacy_user = @table.get_item(key: { "UserId" => user_id }).item

      raise Errors::UserMissing unless user && legacy_user

      current_opt_out = user["Attributes"].fetch("OptOut", false)
      user["Attributes"].merge!("OptOut" => !current_opt_out)

      @table.put_item(
        item: {
          "UserId" => user_id,
          "CreatedAt" => user["Attributes"]["CreatedAt"],
          "BearerToken" => legacy_user["BearerToken"],
          "OneLoginSub" => legacy_user["OneLoginSub"],
          "EmailAddress" => user["Attributes"]["EmailAddress"],
          "OptOut" => user["Attributes"]["OptOut"],
        },
      )

      @table_v2.put_item(
        item: user,
      )
    end

    def delete_user(user_id)
      # Delete from legacy table
      @table.delete_item(
        key: { "UserId" => user_id },
      )

      # Delete from new table
      items_to_delete = @table_v2.query(
        key_condition_expression: "UserId = :pk",
        expression_attribute_values: {
          ":pk" => user_id,
        },
      ).items

      items_to_delete.each_slice(25) do |slice|
        transact_items = slice.map do |row|
          {
            delete: {
              table_name: @table_v2.name,
              key: {
                "UserId" => row["UserId"],
                "Type" => row["Type"],
              },
            },
          }
        end

        @table_v2.client.transact_write_items(
          transact_items:,
        )
      end
    end

  private

    def get_dynamo_db_client
      if Aws.config.dig(:dynamodb, :client)
        # Used to inject a stubbed client in config_test.ru
        Aws.config[:dynamodb][:client]
      elsif ENV["APP_ENV"] == "production"
        Aws::DynamoDB::Client.new(region: "eu-west-2")
      elsif ENV.fetch("APP_ENV", "development") == "development" && ENV["AWS_ENDPOINT_URL_DYNAMODB"]
        Aws::DynamoDB::Client.new(
          endpoint: ENV["AWS_ENDPOINT_URL_DYNAMODB"],
          region: "eu-west-2",
          credentials: Aws::Credentials.new(
            ENV["AWS_ACCESS_KEY_ID"],
            ENV["AWS_SECRET_ACCESS_KEY"],
          ),
        )
      else
        Aws::DynamoDB::Client.new(stub_responses: true)
      end
    end
  end
end
