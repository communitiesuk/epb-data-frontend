require "aws-sdk-dynamodb"

module Gateway
  class UserCredentialsGateway
    def initialize(dynamo_db_client: nil)
      table_name = ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"]
      client = dynamo_db_client || get_dynamo_db_client
      @dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = @dynamo_resource.table(table_name)
    end

    def insert_user(one_login_sub)
      user_id = SecureRandom.uuid
      new_user = {
        "UserId" => user_id,
        "CreatedAt" => Time.now.to_s,
        "BearerToken" => SecureRandom.alphanumeric(64),
        "OneLoginSub" => one_login_sub,
      }

      @table.put_item(
        item: new_user,
      )
      user_id
    end

    def get_user(one_login_sub)
      response = @table.scan(
        filter_expression: "OneLoginSub = :sub",
        expression_attribute_values: {
          ":sub" => one_login_sub,
        },
      )

      raise Errors::MultipleUsersWithSameSubError if response.count > 1

      response.count.zero? ? nil : response.items.first["UserId"]
    end

    def get_user_token(user_id)
      response = @table.get_item(
        key: {
          "UserId" => user_id,
        },
      )
      raise Errors::BearerTokenMissing unless response.item

      response.item["BearerToken"]
    end

  private

    def get_dynamo_db_client
      case ENV["APP_ENV"]
      when "local", nil
        Aws::DynamoDB::Client.new(stub_responses: true)
      else
        Aws::DynamoDB::Client.new(region: "eu-west-2")
      end
    end
  end
end
