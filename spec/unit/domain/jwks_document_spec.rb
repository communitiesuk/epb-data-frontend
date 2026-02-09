describe Domain::JwksDocument do
  subject(:domain) { described_class.new(response:, token_response_hash:) }

  let(:token_response_hash) do
    {
      "access_token": "SlAV32hkKG",
      "token_type": "Bearer",
      "expires_in": 180,
      "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg",
    }
  end

  let(:jwks_document) do
    body = <<~DOC
      {
        "keys": [
          {
            "kty": "EC",
            "use": "sig",
            "crv": "P-256",
            "kid": "644af598b780f54106ca0f3c017341bc230c4f8373f35f32e18e3e40cc7acff6",
            "x": "5URVCgH4HQgkg37kiipfOGjyVft0R5CdjFJahRoJjEw",
            "y": "QzrvsnDy3oY1yuz55voaAq9B1M5tfhgW3FBjh_n_F0U",
            "alg": "ES256"
          },
          {
            "kty": "EC",
            "use": "sig",
            "crv": "P-256",
            "kid": "355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb",
            "x": "BJnIZvnzJ9D_YRu5YL8a3CXjBaa5AxlX1xSeWDLAn9k",
            "y": "x4FU3lRtkeDukSWVJmDuw2nHVFVIZ8_69n4bJ6ik4bQ",
            "alg": "RS256"
          },
          {
            "kty": "RSA",
            "e": "AQAB",
            "use": "sig",
            "kid": "76e79bfc350137593e5bd992b202e248fc97e7a20988a5d4fbe9a0273e54844e",
            "alg": "RS256",
            "n": "lGac-hw2cW5_amtNiDI-Nq2dEXt1x0nwOEIEFd8NwtYz7ha1GzNwO2LyFEoOvqIAcG0NFCAxgjkKD5QwcsThGijvMOLG3dPRMjhyB2S4bCmlkwLpW8vY4sJjc4bItdfuBtUxDA0SWqepr5h95RAsg9UP1LToJecJJR_duMzN-Nutu9qwbpIJph8tFjOFp_T37bVFk4vYkWfX-d4-TOImOOD75G0kgYoAJLS2SRovQAkbJwC1bdn_N8yw7RL9WIqZCwzqMqANdo3dEgSb04XD_CUzL0Y2zU3onewH9PhaMfb11JhsuijH3zRA0dwignDHp7pBw8uMxYSqhoeVO6V0jz8vYo27LyySR1ZLMg13bPNrtMnEC-LlRtZpxkcDLm7bkO-mPjYLrhGpDy7fSdr-6b2rsHzE_YerkZA_RgX_Qv-dZueX5tq2VRZu66QJAgdprZrUx34QBitSAvHL4zcI_Qn2aNl93DR-bT8lrkwB6UBz7EghmQivrwK84BjPircDWdivT4GcEzRdP0ed6PmpAmerHaalyWpLUNoIgVXLa_Px07SweNzyb13QFbiEaJ8p1UFT05KzIRxO8p18g7gWpH8-6jfkZtTOtJJKseNRSyKHgUK5eO9kgvy9sRXmmflV6pl4AMOEwMf4gZpbKtnLh4NETdGg5oSXEuTiF2MjmXE"
          }
        ]
      }

    DOC

    JSON.parse(body)
  end

  let(:response) { { jwks: jwks_document, cache_control: "max-age=3600" } }

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

  describe "#validate_id_token" do
    context "when the id_token is valid" do
      it "returns true" do
        expect(domain.validate_id_token).to be_truthy
      end

      context "when the alg does not match" do
        let(:jwks_document) do
          body = <<~DOC
            {
              "keys": [
                {
                  "kty": "EC",
                  "use": "sig",
                  "crv": "P-256",
                  "kid": "355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb",
                  "x": "BJnIZvnzJ9D_YRu5YL8a3CXjBaa5AxlX1xSeWDLAn9k",
                  "y": "x4FU3lRtkeDukSWVJmDuw2nHVFVIZ8_69n4bJ6ik4bQ",
                  "alg": "ES256"
                }
              ]
            }

          DOC

          JSON.parse(body)
        end

        it "returns false" do
          expect(domain.validate_id_token).to be false
        end
      end
    end

    context "when the id_token is not valid" do
      let(:jwks_document) do
        body = <<~DOC
          {
            "keys": [
              {
                "kty": "EC",
                "use": "sig",
                "crv": "P-256",
                "kid": "644af598b780f54106ca0f3c017341bc230c4f8373f35f32e18e3e40cc7acff6",
                "x": "5URVCgH4HQgkg37kiipfOGjyVft0R5CdjFJahRoJjEw",
                "y": "QzrvsnDy3oY1yuz55voaAq9B1M5tfhgW3FBjh_n_F0U",
                "alg": "ES256"
              }
            ]
          }

        DOC

        JSON.parse(body)
      end

      it "raises an Authentication error" do
        expect { domain.validate_id_token }.to raise_error(Errors::AuthenticationError, "No matching key was found in the JWKS document for the kid")
      end
    end
  end
end
