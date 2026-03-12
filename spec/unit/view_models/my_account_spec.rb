describe ViewModels::MyAccount do
  let(:view_model) { described_class }

  let(:session) { { "user_id": "bec4wweyv34fieH" } }

  let(:get_user_info_use_case) { instance_double(UseCase::GetUserInfo) }

  let(:container) { instance_double(Container) }

  before do
    allow(container).to receive(:get_object).with(:get_user_info_use_case).and_return(get_user_info_use_case)
    allow(get_user_info_use_case).to receive(:execute).and_return({ bearer_token: "mock-bearer-token", opt_out: true })
  end

  describe "#get_bearer_token" do
    it "returns the bearer token from the user info" do
      bearer_token = view_model.get_bearer_token({ bearer_token: "mock-bearer-token" })
      expect(bearer_token).to eq("mock-bearer-token")
    end
  end

  describe "#get_opt_out" do
    it "returns the opt-out value from the user info" do
      opt_out = view_model.get_opt_out({ bearer_token: "mock-bearer-token", opt_out: false })
      expect(opt_out).to be false
    end
  end

  describe "#opt_out_description" do
    it "returns the opt-out disabled text" do
      opt_out_description = view_model.get_opt_out_description({ bearer_token: "mock-bearer-token", opt_out: false })
      expect(opt_out_description).to eq("You may get email notifications about changes to the service.")
    end

    it "returns the opt-out enabled text" do
      opt_out_description = view_model.get_opt_out_description({ bearer_token: "mock-bearer-token", opt_out: true })
      expect(opt_out_description).to eq("You have opted out of email notifications about changes to the service.")
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
