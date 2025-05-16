describe "Acceptance::Jwks", type: :feature do
  include RSpecFrontendServiceMixin
  let(:jwks_url) do
    "http://get-energy-performance-data/jwks"
  end

  let(:response) { get jwks_url }

  describe "get .get-energy-certificate-data.epb-frontend/jwks" do
    context "when the request received" do
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
        expect(response_hash["kid"]).to eq("355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb")
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
