describe Helper::Onelogin, type: :helper do
  subject(:helper) { described_class }

  let(:client_id) { "test_client_id" }
  let(:aud) { "test_aud" }
  let(:state) { "test_state" }
  let(:nonce) { "test_nonce" }
  let(:redirect_uri) { "https://example.com/test" }
  let(:request) { { key: "test_value" } }

  describe "#get_authorize_request" do
    it "returns a valid authorization request hash" do
      result = helper.get_authorize_request(client_id, aud, state, nonce, redirect_uri)
      expect(result).to include(
        aud: aud,
        iss: client_id,
        response_type: "code",
        client_id: client_id,
        redirect_uri: redirect_uri,
        scope: "openid email",
        state: state,
        nonce: nonce,
        vtr: '["Cl.Cm"]',
        ui_locales: "en",
      )
    end
  end

  describe "#get_jwt_assertion" do
    before do
      Timecop.freeze(Time.utc(2026, 6, 1))
    end

    after do
      Timecop.return
    end

    it "returns a valid jwt assertion body" do
      jti = "test_jti"
      result = helper.get_jwt_assertion_body(client_id, aud, jti)
      expect(result).to include(
        aud: aud,
        iss: client_id,
        sub: client_id,
        jti: jti,
        exp: 1_780_272_300,
        iat: 1_780_272_000,
      )
    end
  end

  describe "#sign_jwt" do
    it "signs the request successfully" do
      signature = described_class.sign_jwt(request)
      expect(signature).not_to be_nil
    end

    it "raises an error if ONELOGIN_TLS_KEYS is missing" do
      env_var = ENV["ONELOGIN_TLS_KEYS"]
      ENV.delete("ONELOGIN_TLS_KEYS")

      expect { helper.sign_jwt(request) }.to raise_error(Errors::MissingEnvVariable)

      ENV["ONELOGIN_TLS_KEYS"] = env_var
    end

    it "raises an error if signing fails" do
      allow(OpenSSL::PKey::RSA).to receive(:new).and_raise(StandardError, "Test error")
      expect { described_class.sign_jwt(request) }.to raise_error(Errors::OneloginSigningError, /Failed to sign request: Test error/)
    end
  end

  describe "#check_one_login_errors" do
    context "when access_denied error is present" do
      it "raises AccessDenied error" do
        params = { error: "access_denied", error_description: "Test description" }
        expect { helper.check_one_login_errors(params) }.to raise_error(Errors::AccessDeniedError, /OneLogin callback: Access denied. Description: Test description/)
      end
    end

    context "when login_required error is present" do
      it "raises LoginRequiredError error" do
        params = { error: "login_required", error_description: "Test description" }
        expect { helper.check_one_login_errors(params) }.to raise_error(Errors::LoginRequiredError, /OneLogin callback: Login required. Description: Test description/)
      end
    end

    context "when any other OneLogin error is present" do
      it "raises AuthenticationError error" do
        params = { error: "invalid_request", error_description: "Test description" }
        expect { helper.check_one_login_errors(params) }.to raise_error(Errors::AuthenticationError, /OneLogin callback: Error received: invalid_request. Description: Test description/)
      end
    end
  end

  describe "#validate_state_cookie" do
    state = "test_state"
    different_state = "different_state"
    context "when state matches" do
      it "does not raise an error" do
        expect { described_class.validate_state_cookie(state, state) }.not_to raise_error
      end
    end

    context "when state does not match" do
      it "raises an error" do
        expect { described_class.validate_state_cookie(different_state, state) }.to raise_error(Errors::StateMismatch, /State mismatch. Expected #{state}, got #{different_state}/)
      end
    end
  end

  describe "#set_user_one_login_info" do
    let(:token_response_hash) do
      {
        "access_token": "SlAV32hkKG",
        "token_type": "Bearer",
        "expires_in": 180,
        "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg",
      }.transform_keys(&:to_s)
    end

    let(:container) do
      instance_double(Container)
    end

    let(:session) do
      { nonce: "" }
    end

    let(:get_onelogin_user_info_use_case) do
      instance_double(UseCase::GetOneloginUserInfo)
    end

    let(:user_info) do
      { email: "test@example.com", email_verified: true, sub: "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw=" }
    end

    let(:onelogin_gateway) do
      instance_double(Gateway::OneloginGateway)
    end

    let(:get_user_id_use_case) do
      instance_double(UseCase::GetUserId)
    end

    before do
      allow(container).to receive(:get_object).with(:get_onelogin_user_info_use_case).and_return(get_onelogin_user_info_use_case)
      allow(container).to receive(:get_object).with(:get_user_id_use_case).and_return(get_user_id_use_case)
      allow(get_onelogin_user_info_use_case).to receive(:execute).and_return(user_info)
      allow(get_user_id_use_case).to receive(:execute).and_return("mock-user-token")
      allow(Helper::Session).to receive(:set_session_value)
    end

    it "calls the GetUserId use case" do
      described_class.set_user_one_login_info(container:, session:, token_response_hash:)
      expect(get_user_id_use_case).to have_received(:execute).once
    end

    it "calls the GetOneloginUserInfo use case" do
      described_class.set_user_one_login_info(container:, session:, token_response_hash:)
      expect(get_onelogin_user_info_use_case).to have_received(:execute).once
    end

    it "sets the session with the user's email" do
      described_class.set_user_one_login_info(container:, session:, token_response_hash:)
      expect(Helper::Session).to have_received(:set_session_value).with(session, :email_address, user_info[:email]).once
    end

    it "sets the session with the user's token id" do
      described_class.set_user_one_login_info(container:, session:, token_response_hash:)
      expect(Helper::Session).to have_received(:set_session_value).with(session, :id_token, token_response_hash["id_token"]).once
    end

    it "sets the session with the user's user_id" do
      described_class.set_user_one_login_info(container:, session:, token_response_hash:)
      expect(Helper::Session).to have_received(:set_session_value).with(session, :user_id, "mock-user-token").once
    end

    context "when the session is set for users of the opt out" do
      it "sets the session without making a call to dynamo db" do
        described_class.set_user_one_login_info(container:, session:, token_response_hash:, is_opt_out: true)
        expect(get_user_id_use_case).to have_received(:execute).exactly(0).times
        expect(Helper::Session).to have_received(:set_session_value).with(session, :user_id, nil).once
      end
    end
  end
end
