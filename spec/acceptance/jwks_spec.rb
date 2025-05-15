describe "Acceptance::Jwks", type: :feature do
  include RSpecFrontendServiceMixin
  let(:jwks_url) do
    "http://get-energy-performance-data/jwks"
  end

  let(:response) { get jwks_url }

  describe "get .get-energy-certificate-data.epb-frontend/jwks" do
    context "when the request received" do
      before do
        ENV["ONELOGIN_TLS_KEYS"] = {
          kid: "test-key-id",
          public_key: "-----BEGIN PUBLIC KEY-----\n" \
            "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArGvxQU80uOxKzlmbCHNO\n" \
            "kjcgTF415lSHTmbr3x8jFEHvXu+NzXD0qHMIIQ217foYJAwT/RdTpaaeOW7sXdIq\n" \
            "gAUhQwCNhSyuTx0sIMM0G0YXHOmLXAiRzwApLBxKYYU4i66T6ACP7Io0pDEqHu0s\n" \
            "FrfdnfV+3JaaRlWkGXpKarwMtMAhzSdE5UGgxJ08d7qLJ/g8lbQZxcrVmyLragmY\n" \
            "HEfzgAYyv8WFKEj2n0rcFzntcjZXy9EZOxlFqMn27Vr/lz+Yye2zio4+j/d8S8Q6\n" \
            "V1oddVHwMAB8rG+CaTJg+63Z61dtStYMxIl2CFBld4UpWTkWrGdmHnKkYZeZRnrm\n" \
            "7QIDAQAB\n" \
            "-----END PUBLIC KEY-----",
        }.to_json
      end

      after do
        ENV.delete("ONELOGIN_TLS_KEYS")
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "returns valid json" do
        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it "includes all the required keys" do
        response_hash = JSON.parse(response.body)
        expect(response_hash.keys.sort).to eq(%w[e kid kty n use])
      end

      it "returns the expected data" do
        response_hash = JSON.parse(response.body)
        expect(response_hash["kty"]).to eq("RSA")
        expect(response_hash["kid"]).to eq("test-key-id")
        expect(response_hash["use"]).to eq("sig")
        expect(response_hash["e"]).to eq("AQAB")
      end

      it "returns the expected encoded modulus on 'n' key" do
        response_hash = JSON.parse(response.body)
        public_key_pem = JSON.parse(ENV["ONELOGIN_TLS_KEYS"])["public_key"]
        modulus = OpenSSL::PKey::RSA.new(public_key_pem).n

        # Calculate manually encoded modulus string
        bytes = modulus.to_s(16)
        bytes = "0#{bytes}" if bytes.length.odd? # Ensure even-length hex string
        binary = [bytes].pack("H*")
        expected_n = Base64.urlsafe_encode64(binary).delete("=")

        expect(response_hash["n"]).to eq(expected_n)
      end

      it "returns application/json content type" do
        expect(response.headers["Content-Type"]).to eq("application/json")
      end
    end
  end
end
