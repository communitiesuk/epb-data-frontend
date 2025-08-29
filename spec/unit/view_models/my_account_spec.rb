describe ViewModels::MyAccount do
  let(:view_model) { described_class }

  let(:session) { { "user_id": "bec4wweyv34fieH" } }

  describe "#get_bearer_token" do
    let(:get_user_token_use_case) { instance_double(UseCase::GetUserToken) }

    let(:container) { instance_double(Container) }

    before do
      allow(Helper::Session).to receive(:get_session_value).and_return("test-user-id")
      allow(container).to receive(:get_object).with(:get_user_token_use_case).and_return(get_user_token_use_case)
      allow(get_user_token_use_case).to receive(:execute).and_return("mock-bearer-token")
    end

    it "returns the bearer token from the use case" do
      bearer_token = view_model.get_bearer_token(session, get_user_token_use_case)
      expect(bearer_token).to eq("mock-bearer-token")
    end
  end

  describe "#get_email_address" do
    before do
      allow(Helper::Session).to receive(:get_email_from_session).and_return("email@test.com")
    end

    it "returns the email address from the session" do
      expect(view_model.get_email_address(session)).to eq("email@test.com")
    end
  end
end
