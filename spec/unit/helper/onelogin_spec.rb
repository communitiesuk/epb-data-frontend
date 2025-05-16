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
        vtr: '["Cl.CM.P2"]',
        ui_locales: "en",
        claims: {
          "userinfo": {
            "https://vocab.account.gov.uk/v1/coreIdentityJWT": nil,
          },
        },
      )
    end
  end

  describe "#sign_request" do
    it "signs the request successfully" do
      signature = described_class.sign_request(request)
      expect(signature).not_to be_nil
    end

    it "raises an error if ONELOGIN_TLS_KEYS is missing" do
      env_var = ENV["ONELOGIN_TLS_KEYS"]
      ENV.delete("ONELOGIN_TLS_KEYS")

      expect { helper.sign_request(request) }.to raise_error(Errors::MissingEnvVariable)

      ENV["ONELOGIN_TLS_KEYS"] = env_var
    end

    it "raises an error if signing fails" do
      allow(OpenSSL::PKey::RSA).to receive(:new).and_raise(StandardError, "Test error")
      expect { described_class.sign_request(request) }.to raise_error(Errors::OneloginSigningError, /Failed to sign request: Test error/)
    end
  end
end
