describe UseCase::GetOneloginUserInfo do
  subject(:use_case) { described_class.new(onelogin_gateway:) }

  let(:onelogin_gateway) do
    instance_double(Gateway::OneloginGateway)
  end

  describe "#execute" do
    let(:access_token) do
      "test_access_token"
    end

    let(:expected_response) do
      { email: "test@example.com", email_verified: true, sub: "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw=" }
    end

    context "when executed" do
      before do
        allow(onelogin_gateway).to receive(:get_user_info).and_return(expected_response)
      end

      it "calls the gateway with the correct arguments" do
        use_case.execute(access_token:)
        expect(onelogin_gateway).to have_received(:get_user_info).with(access_token:).exactly(1).times
      end

      it "returns the expected data" do
        expect(use_case.execute(access_token:)).to eq expected_response
      end
    end
  end
end
