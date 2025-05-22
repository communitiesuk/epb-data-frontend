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
end
