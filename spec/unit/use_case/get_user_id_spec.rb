describe UseCase::GetUserId do
  let(:user_credentials_gateway) do
    instance_double(Gateway::UserCredentialsGateway)
  end

  let(:use_case) do
    described_class.new(user_credentials_gateway:)
  end

  context "when the user exists" do
    before do
      allow(user_credentials_gateway).to receive(:get_user).and_return("mock-user-id")
      allow(user_credentials_gateway).to receive(:insert_user)
      use_case.execute("one-sub")
    end

    it "returns the user_id" do
      expect(use_case.execute("one-sub")).to eq("mock-user-id")
    end

    it "calls get_user on the gateway" do
      expect(user_credentials_gateway).to have_received(:get_user).with("one-sub").exactly(:once)
    end

    it "does not call insert_user on the gateway" do
      expect(user_credentials_gateway).not_to have_received(:insert_user)
    end
  end

  context "when the user does not exist" do
    before do
      allow(user_credentials_gateway).to receive_messages(
        get_user: nil,
        insert_user: "new-user-id",
      )
      use_case.execute("another-sub")
    end

    it "returns the user_id" do
      expect(use_case.execute("another-sub")).to eq("new-user-id")
    end

    it "calls get_user on the gateway" do
      expect(user_credentials_gateway).to have_received(:get_user).with("another-sub").exactly(:once)
    end

    it "inserts an user" do
      expect(user_credentials_gateway).to have_received(:insert_user).with("another-sub").exactly(:once)
    end
  end
end
