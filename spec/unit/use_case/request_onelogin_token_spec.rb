describe UseCase::RequestOneloginToken do
  subject(:use_case) { described_class.new(onelogin_gateway:) }

  let(:onelogin_gateway) do
    instance_double(Gateway::OneloginGateway)
  end

  let(:client_id) do
    "test_client_id"
  end

  let(:one_login_host) do
    "test_host"
  end

  let(:code) do
    "test_auth_code"
  end

  let(:redirect_uri) do
    "test_redirect_uri"
  end

  let(:expected_jwt_assertion) do
    "eyJraWQiOiIzNTVhNWMzZC03YTIxLTRlMWUtOGFiOS1hYTE0YzMzZDgzZmIiLCJhbGciOiJSUzI1NiJ9." \
    "eyJhdWQiOiJ0ZXN0X2hvc3QvdG9rZW4iLCJpc3MiOiJ0ZXN0X2NsaWVudF9pZCIsInN1YiI6InRlc3RfY2xpZW50" \
    "X2lkIiwiZXhwIjoxNzc3ODUzMTAwLCJqdGkiOiJtb2NrZWRoZXh2YWx1ZTEyMzQ1Njc4OTAiLCJpYXQiOjE3Nzc4" \
    "NTI4MDB9.hRRS9HQzMXes_3PIFJFMDHaxOBdl5CcfIVV-OzGMIViMCs-zPZGUoG1P5jxSb_vAmt3yaxk3dx5s-Uog" \
    "j9GFaeYAXAEc6Zf1qk1Fl-_uqG-AWZXdtRPoKfXnqh7wCi600F62rGm_hx7Uo73WUMh5kmhSor3upb8tCXewj-COq" \
    "mVfZOT9cU0so6KDiZ8EaEpiBqtWLJOQG0QT_VfWNHg8xOd4o12uTw5ViPf3gxIc-yiL7Lx0gQje0viQpqgsP1jSh0" \
    "TECxXy0wIkKmhap7Gb9M03GAQSiNAYNRcnWpVH3xmBSAfD2rflOxRs6fnYH5f-L8smdBQCAhEJRukcuUT1IQ"
  end

  before do
    Timecop.freeze(Time.utc(2026, 5, 4))
    allow(SecureRandom).to receive(:hex).with(16).and_return("mockedhexvalue1234567890")
  end

  after do
    Timecop.return
  end

  describe "#execute" do
    context "when executed" do
      before do
        allow(onelogin_gateway).to receive(:get_token)
      end

      it "calls the gateway with the correct arguments" do
        use_case.execute(code:, redirect_uri:)
        expect(onelogin_gateway).to have_received(:get_token).with(code:, redirect_uri:, jwt_assertion: anything).exactly(1).times
      end
    end
  end

  describe "#generate_client_jwt_assertion" do
    context "when the request is valid" do
      it "returns the signed request" do
        result = use_case.send(:generate_client_jwt_assertion, client_id, one_login_host)
        expect(result).to eq(expected_jwt_assertion.force_encoding("ASCII-8BIT"))
      end
    end
  end
end
