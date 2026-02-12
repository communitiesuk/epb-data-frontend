describe Helper::VerifyTokenSignature do
  describe "#get_payload" do
    let(:helper) { described_class }

    let(:onelogin_tls_keys) do
      JSON.parse(ENV.fetch("ONELOGIN_TLS_KEYS"))
    end
    let(:jwks_key) do
      JWT::JWK.new(public_key)
    end
    let(:private_key) do
      key_pem = onelogin_tls_keys["private_key"]
      OpenSSL::PKey::RSA.new(key_pem)
    end
    let(:public_key) do
      key_pem = onelogin_tls_keys["public_key"]
      OpenSSL::PKey::RSA.new(key_pem)
    end
    let(:invalid_private_key) do
      OpenSSL::PKey::RSA.generate(2048)
    end
    let(:algorithm) { "RS256" }
    let(:kid) do
      "355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb"
    end

    let(:token_response_hash) do
      {
        "access_token": "SlAV32hkKG",
        "token_type": "Bearer",
        "expires_in": 180,
        "id_token": JWT.encode(payload, private_key, algorithm, { kid: kid }),
      }
    end
    let(:payload) do
      body = <<~DOC
        {
          "at_hash": "ZDevf74CkYWNPa8qmflQyA",
          "sub": "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4",
          "aud": "#{ENV['ONELOGIN_CLIENT_ID']}",
          "iss": "https://oidc.integration.account.gov.uk/",
          "vot": "Cl.Cm",
          "exp": #{Time.now.to_i + 10},
          "iat": #{Time.now.to_i - 10},
          "nonce": "lZk16Vmu8-h7r8L8bFFiHJxpC3L73UBpfb68WC1Qoqg",
          "vtm": "https://oidc.integration.account.gov.uk/trustmark",
          "sid": "dX5xv0XgHh6yfD1xy-ss_1EDK0I",
          "auth_time": #{Time.now.to_i - 20}
         }
      DOC

      JSON.parse(body)
    end
    let(:id_token) do
      token_response_hash[:id_token]
    end

    context "when the signature is signed with the correct private key" do
      it "returns id token payload if we can decode with the corresponding public key" do
        expect(helper.get_payload(jwks_document_key: jwks_key, alg: algorithm, id_token:))
          .to eq(payload)
      end
    end

    context "when the token has expired" do
      before do
        expired_payload = payload.merge(exp: Time.now.to_i - 300)
        token_response_hash[:id_token] = JWT.encode(expired_payload, private_key, algorithm, { kid: kid })
      end

      it "raises an Authentication error (verify_expiration)" do
        expect { helper.get_payload(jwks_document_key: jwks_key, alg: algorithm, id_token:) }
          .to raise_error(Errors::ValidationError, /ID token signature verification failed/i)
      end
    end

    context "when the token has an iat in the future" do
      before do
        future_iat_payload = payload.merge(iat: Time.now.to_i + 300, exp: Time.now.to_i + 600)
        token_response_hash[:id_token] = JWT.encode(future_iat_payload, private_key, algorithm, { kid: kid })
      end

      it "raises an Authentication error (verify_iat)" do
        expect { helper.get_payload(jwks_document_key: jwks_key, alg: algorithm, id_token:) }
          .to raise_error(Errors::ValidationError, /ID token signature verification failed/i)
      end
    end

    context "when verifying the signature with an invalid key" do
      before do
        token_response_hash[:id_token] = JWT.encode(payload, invalid_private_key, algorithm, { kid: kid })
      end

      it "raise an error" do
        expect { helper.get_payload(jwks_document_key: jwks_key, alg: algorithm, id_token:) }.to raise_error(Errors::ValidationError, /ID token signature verification failed/)
      end
    end

    context "when signature has expired" do
      context "when the exp claim is in the past" do
        before do
          payload["exp"] = 1_704_894_526
        end

        it "raises an Authentication error" do
          expect { helper.get_payload(jwks_document_key: jwks_key, alg: algorithm, id_token:) }.to raise_error(Errors::ValidationError, /ID token signature verification failed: Signature has expired/)
        end
      end

      context "when the issued at claim is in the future" do
        before do
          payload["iat"] = Time.now.to_i + 300
          payload["exp"] = Time.now.to_i + 600
        end

        it "raises an Authentication error" do
          expect { helper.get_payload(jwks_document_key: jwks_key, alg: algorithm, id_token:) }.to raise_error(Errors::ValidationError, /ID token signature verification failed: Invalid iat/)
        end
      end
    end
  end
end
