describe UseCase::GetOneloginUserInfo do
  subject(:use_case) { described_class.new(onelogin_gateway:) }

  let(:onelogin_gateway) do
    instance_double(Gateway::OneloginGateway)
  end

  describe "#execute" do
    let(:access_token) do
      "test_access_token"
    end

    context "when executed" do
      before do
        allow(onelogin_gateway).to receive(:get_user_info)
      end

      it "calls the gateway with the correct arguments" do
        use_case.execute(access_token:)
        expect(onelogin_gateway).to have_received(:get_user_info).with(access_token:).exactly(1).times
      end
    end
  end
end
