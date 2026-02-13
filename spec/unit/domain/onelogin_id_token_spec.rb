require_relative "../../shared_context/shared_id_token_validation"

describe Domain::OneloginIdToken do
  subject(:domain) { described_class.new(response:, token_response_hash:, nonce:, vtr:) }

  let(:expected_mathing_key) do
    jwks_document["keys"][2]
  end

  include_context "when validating id token"

  describe "#extract_max_age_from_cache_control" do
    context "when cache-control header is present" do
      it "returns the max-age value" do
        expect(domain.extract_max_age_from_cache_control).to eq(3600)
      end
    end

    context "when cache-control header is not present" do
      let(:jwks_document) { nil }

      let(:response) { { jwks: jwks_document } }

      it "returns nil" do
        expect(domain.extract_max_age_from_cache_control).to be_nil
      end
    end
  end

  describe "#fetch_matching_key" do
    context "when the match is for a kid and alg" do
      it "returns a matching key" do
        expect(domain.fetch_matching_key).to be(expected_mathing_key)
      end
    end

    context "when no matching key is found" do
      before do
        jwks_document["keys"][2]["kid"] = "another_kid"
      end

      it "returns a matching key" do
        expect { domain.fetch_matching_key }.to raise_error(Errors::ValidationError, "No matching key was found in the JWKS document for the kid")
      end
    end

    context "when matching key is found but alg does not match" do
      before do
        jwks_document["keys"][2]["kid"] = kid
        jwks_document["keys"][2]["alg"] = "ES256"
      end

      it "returns a matching key" do
        expect { domain.fetch_matching_key }.to raise_error(Errors::ValidationError, "The alg in the JWKS document does not match the algorithm (alg) in the ID token")
      end
    end
  end

  describe "#verify_signature" do
    let(:other_private_key) do
      OpenSSL::PKey::RSA.generate(2048)
    end

    let(:id_token) do
      token_response_hash[:id_token]
    end

    context "when the signature is valid" do
      before do
        domain.fetch_matching_key
      end

      it "returns the payload" do
        expect(domain.verify_signature(alg: algorithm)).to eq(payload)
      end
    end

    context "when verifying the signature that was signed with a different private key" do
      before do
        token_response_hash[:id_token] = JWT.encode(payload, other_private_key, algorithm, { kid: kid })
      end

      it "raise an error" do
        expect { domain.verify_signature(alg: algorithm) }.to raise_error(Errors::ValidationError, /ID token signature verification failed/)
      end
    end

    context "when the id token has expired" do
      before do
        expired_payload = payload.merge("exp" => Time.now.to_i - 300)
        token_response_hash[:id_token] = JWT.encode(expired_payload, private_key, algorithm, { kid: kid })
        domain.fetch_matching_key
      end

      it "raises an Authentication error (verify_expiration)" do
        expect { domain.verify_signature(alg: algorithm) }
          .to raise_error(Errors::ValidationError, /ID token has expired: Signature has expired/i)
      end
    end

    context "when the token has an iat in the future" do
      before do
        future_iat_payload = payload.merge(iat: Time.now.to_i + 300, exp: Time.now.to_i + 600)
        token_response_hash[:id_token] = JWT.encode(future_iat_payload, private_key, algorithm, { kid: kid })
        domain.fetch_matching_key
      end

      it "raises an Authentication error (verify_iat)" do
        expect { domain.verify_signature(alg: algorithm) }
          .to raise_error(Errors::ValidationError, /ID token signature verification failed: Invalid iat/i)
      end
    end
  end

  describe "#validate_claims" do
    context "when all claims are valid" do
      before do
        domain.fetch_matching_key
        domain.verify_signature(alg: algorithm)
      end

      it "returns true" do
        expect(domain.validate_claims).to be true
      end
    end

    context "when the id token issuer does not match" do
      before do
        invalid_issuer_payload = payload.merge("iss" => "https://invalid-issuer.com/")
        token_response_hash[:id_token] = JWT.encode(invalid_issuer_payload, private_key, algorithm, { kid: kid })

        domain.fetch_matching_key
        domain.verify_signature(alg: algorithm)
      end

      it "raises an Authentication error" do
        expect { domain.validate_claims }.to raise_error(Errors::ValidationError, /Invalid id token issuer/)
      end
    end

    context "when the audience claim does not match the expected client id" do
      before do
        invalid_audience_payload = payload.merge("aud" => "invalid-audience")
        token_response_hash[:id_token] = JWT.encode(invalid_audience_payload, private_key, algorithm, { kid: kid })

        domain.fetch_matching_key
        domain.verify_signature(alg: algorithm)
      end

      it "raises an Authentication error" do
        expect { domain.validate_claims }.to raise_error(Errors::ValidationError, /Invalid id token audience/)
      end
    end

    context "when nonce value in the payload does not match the nonce in the /login/authorize request" do
      before do
        invalid_nonce_payload = payload.merge("nonce" => "invalid-nonce-value")
        token_response_hash[:id_token] = JWT.encode(invalid_nonce_payload, private_key, algorithm, { kid: kid })

        domain.fetch_matching_key
        domain.verify_signature(alg: algorithm)
      end

      it "raises an Authentication error" do
        expect { domain.validate_claims }.to raise_error(Errors::ValidationError, /Invalid id token nonce/)
      end
    end

    context "when vtr in the login authorize request does not match the vot in the id token payload" do
      before do
        invalid_vot_payload = payload.merge("vot" => "invalid-vot")
        token_response_hash[:id_token] = JWT.encode(invalid_vot_payload, private_key, algorithm, { kid: kid })

        domain.fetch_matching_key
        domain.verify_signature(alg: algorithm)
      end

      it "raises an Authentication error" do
        expect { domain.validate_claims }.to raise_error(Errors::ValidationError, /The vtr in the login authorize request does not include the vot in the id token payload/)
      end
    end
  end
end
