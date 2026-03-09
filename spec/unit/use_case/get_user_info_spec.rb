describe UseCase::GetUserInfo do
  let(:user_credentials_gateway) do
    instance_double(Gateway::UserCredentialsGateway)
  end

  let(:use_case) do
    described_class.new(user_credentials_gateway:)
  end

  let(:test_user_id) { "test-user-id" }

  describe "#execute" do
    context "when calling the use case" do
      before do
        allow(user_credentials_gateway).to receive(:get_user_info).and_return({ bearer_token: "mock-user-token", opt_out: false })
      end

      it "returns the user_id" do
        expect(use_case.execute(test_user_id)).to eq({ bearer_token: "mock-user-token", opt_out: false })
      end

      it "calls get_user on the gateway" do
        use_case.execute(test_user_id)
        expect(user_credentials_gateway).to have_received(:get_user_info).with(test_user_id).exactly(:once)
      end
    end
  end
end
