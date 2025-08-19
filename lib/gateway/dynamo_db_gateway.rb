require "aws-sdk-dynamodb"

module Gateway
  class DynamoDbGateway
    def initialize(dynamo_db_client: nil)
      table_name = ENV["EPB_DATA_USERS_TABLE_NAME"]
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

  private

    def get_dynamo_db_client
      case ENV["APP_ENV"]
      when "production"
        Aws::DynamoDB::Client.new(region: "eu-west-2", credentials: Aws::ECSCredentials.new)
      else
        Aws::DynamoDB::Client.new(stub_responses: true)
      end
    end
  end
end
