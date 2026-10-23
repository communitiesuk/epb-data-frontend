describe UseCase::AddBearerToken do
  subject(:use_case) { described_class.new(user_credentials_gateway:) }

  let(:user_credentials_gateway) { instance_double(Gateway::UserCredentialsGateway) }
  let(:user_id) { "test-user-id" }
  let(:new_token) { "new_bearer_token_12345" }

  describe "#execute" do
    context "when user_id is nil" do
      it "raises Errors::UserMissing" do
        expect { use_case.execute(user_id: nil) }.to raise_error(Errors::UserMissing)
      end
    end

    context "when user already has 2 bearer tokens" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_return(%w[token1 token2])
        allow(user_credentials_gateway).to receive(:add_bearer_token)
      end

      it "raises Errors::BearerTokenLimitExceeded" do
        expect { use_case.execute(user_id: user_id) }.to raise_error(Errors::BearerTokenLimitExceeded)
      end

      it "does not call add_bearer_token on the gateway" do
        begin
          use_case.execute(user_id: user_id)
        rescue Errors::BearerTokenLimitExceeded
          # expected
        end
        expect(user_credentials_gateway).not_to have_received(:add_bearer_token)
      end
    end

    context "when user has 1 bearer token" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_return(%w[token1])
        allow(user_credentials_gateway).to receive(:add_bearer_token).with(user_id: user_id).and_return(new_token)
      end

      it "calls add_bearer_token on gateway and returns the new token" do
        expect(use_case.execute(user_id: user_id)).to eq(new_token)
        expect(user_credentials_gateway).to have_received(:add_bearer_token).with(user_id: user_id).once
      end
    end

    context "when user has no bearer token" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_tokens).with(user_id).and_raise(Errors::BearerTokenMissing)
        allow(user_credentials_gateway).to receive(:add_bearer_token).with(user_id: user_id).and_return(new_token)
      end

      it "calls add_bearer_token on gateway and returns the new token" do
        expect(use_case.execute(user_id: user_id)).to eq(new_token)
        expect(user_credentials_gateway).to have_received(:add_bearer_token).with(user_id: user_id).once
      end
    end
  end
end
