describe UseCase::DeleteBearerToken do
  subject(:use_case) { described_class.new(user_credentials_gateway:) }

  let(:user_credentials_gateway) { instance_double(Gateway::UserCredentialsGateway) }
  let(:user_id) { "test-user-id" }
  let(:first_token) { "abcdefghijklmnopqrstu1" }
  let(:second_token) { "abcdefghijklmnopqrstu2" }

  describe "#execute" do
    context "when user_id is nil" do
      it "raises Errors::UserMissing" do
        expect { use_case.execute(user_id: nil, bearer_token: first_token) }.to raise_error(Errors::UserMissing)
      end
    end

    context "when bearer_token is nil or empty" do
      it "raises Errors::BearerTokenMissing when nil" do
        expect { use_case.execute(user_id: user_id, bearer_token: nil) }.to raise_error(Errors::BearerTokenMissing)
      end

      it "raises Errors::BearerTokenMissing when empty string" do
        expect { use_case.execute(user_id: user_id, bearer_token: "") }.to raise_error(Errors::BearerTokenMissing)
      end

      it "raises Errors::BearerTokenMissing when whitespace string" do
        expect { use_case.execute(user_id: user_id, bearer_token: "   ") }.to raise_error(Errors::BearerTokenMissing)
      end
    end

    context "when user has no tokens" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_raise(Errors::BearerTokenMissing)
      end

      it "raises Errors::BearerTokenMissing" do
        expect { use_case.execute(user_id: user_id, bearer_token: first_token) }.to raise_error(Errors::BearerTokenMissing)
      end
    end

    context "when user only has 1 bearer token" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_return([
          first_token,
        ])
        allow(user_credentials_gateway).to receive(:delete_bearer_token)
      end

      it "raises Errors::CannotDeleteLastBearerToken" do
        expect { use_case.execute(user_id: user_id, bearer_token: first_token) }.to raise_error(Errors::CannotDeleteLastBearerToken)
      end

      it "does not call delete_bearer_token on gateway" do
        begin
          use_case.execute(user_id: user_id, bearer_token: first_token)
        rescue Errors::CannotDeleteLastBearerToken
          # expected
        end
        expect(user_credentials_gateway).not_to have_received(:delete_bearer_token)
      end
    end

    context "when user has 2 bearer tokens and deletes a valid token" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_return([
          first_token,
          second_token,
        ])
        allow(user_credentials_gateway).to receive(:delete_bearer_token)
      end

      it "calls delete_bearer_token on gateway" do
        use_case.execute(user_id: user_id, bearer_token: first_token)
        expect(user_credentials_gateway).to have_received(:delete_bearer_token).with(user_id: user_id, bearer_token: first_token).once
      end
    end

    context "when user has 2 bearer tokens but specified token does not exist" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_return([
          first_token,
          second_token,
        ])
        allow(user_credentials_gateway).to receive(:delete_bearer_token)
      end

      it "raises Errors::BearerTokenNotFound (and Errors::BearerTokenMissing)" do
        expect { use_case.execute(user_id:, bearer_token: "unknown_token") }.to raise_error(Errors::BearerTokenNotFound)
        expect { use_case.execute(user_id:, bearer_token: "unknown_token") }.to raise_error(Errors::BearerTokenMissing)
      end

      it "does not call delete_bearer_token on gateway" do
        begin
          use_case.execute(user_id:, bearer_token: "unknown_token")
        rescue Errors::BearerTokenNotFound
          # expected
        end
        expect(user_credentials_gateway).not_to have_received(:delete_bearer_token)
      end
    end
  end
end
