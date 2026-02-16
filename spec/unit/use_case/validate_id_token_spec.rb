require_relative "../../shared_context/shared_id_token_validation"

describe UseCase::ValidateIdToken do
  include_context "when validating id token"

  let(:onelogin_gateway) do
    instance_double(Gateway::OneloginGateway)
  end

  let(:cache) do
    Helper::JwksDocumentCache.new
  end

  let(:use_case) do
    described_class.new(onelogin_gateway:, cache:)
  end

  let(:onelogin_domain) do
    instance_double(Domain::OneloginIdToken)
  end

  describe "#execute" do
    context "when the JWKS document is successfully fetched" do
      before do
        allow(onelogin_domain).to receive_messages(fetch_matching_key: response[:jwks]["keys"][2], verify_signature: true, validate_claims: true)
        allow(onelogin_gateway).to receive(:fetch_jwks_document).and_return(response)
        allow(Domain::OneloginIdToken).to receive(:new).with(anything).and_return(onelogin_domain)
        allow(onelogin_domain).to receive(:extract_max_age_from_cache_control).and_return(3600)
      end

      context "when cache is empty" do
        it "successfully calls the gateway" do
          use_case.execute(token_response_hash:, nonce:)
          expect(onelogin_gateway).to have_received(:fetch_jwks_document).once
        end

        it "initializes domain with the gateway response and token response hash" do
          use_case.execute(token_response_hash:, nonce:)

          expect(Domain::OneloginIdToken).to have_received(:new).with(
            response: response,
            token_response_hash:,
            nonce:,
            vtr: '["Cl.Cm"]',
          )
        end

        it "caches the JWKS document and sets the cache expiry time based on the max-age in the cache control header" do
          use_case.execute(token_response_hash:, nonce:)
          expect(cache.jwks_document).to eq(response)
          expect(cache.expires_at).to eq(Time.now.to_i + 3600)
        end
      end

      context "when the jwks document is already cached" do
        before do
          cache.jwks_document = response
          cache.set_expires_at(Time.now.to_i + 3600)
        end

        it "does not call the gateway" do
          use_case.execute(token_response_hash:, nonce:)
          expect(onelogin_gateway).not_to have_received(:fetch_jwks_document)
        end
      end

      context "when there is an OneLogin outage and the JWKS document is cached" do
        before do
          allow(onelogin_gateway).to receive(:fetch_jwks_document).and_raise(Errors::NetworkError)
        end

        context "when the JWKS document is cached and expired" do
          before do
            cache.jwks_document = response
            cache.set_expires_at(Time.now.to_i - 3600)
          end

          it "rescues the error" do
            expect { use_case.execute(token_response_hash:, nonce:) }.not_to raise_error
          end
        end

        context "when there is no cached JWKS document" do
          before do
            cache.jwks_document = nil
          end

          it "raises an AuthenticationError" do
            expect {
              use_case.execute(token_response_hash:, nonce:)
            }.to raise_error(Errors::AuthenticationError, /Unable to fetch JWKS document and no cached document is available/)
          end
        end
      end

      context "when all validations pass" do
        it "returns true" do
          result = use_case.execute(token_response_hash:, nonce:)
          expect(result).to be(true)
        end
      end
    end

    context "when the verify_signature fails" do
      before do
        allow(onelogin_domain).to receive_messages(fetch_matching_key: response[:jwks]["keys"][2], extract_max_age_from_cache_control: 3600)
        allow(onelogin_domain).to receive(:verify_signature).and_raise(Errors::ValidationError, "ID token signature verification failed: Invalid signature")
        allow(onelogin_gateway).to receive(:fetch_jwks_document).and_return(response)
        allow(Domain::OneloginIdToken).to receive(:new).with(anything).and_return(onelogin_domain)
      end

      it "re-raises the ValidationError" do
        expect {
          use_case.execute(token_response_hash:, nonce:)
        }.to raise_error(Errors::ValidationError, /ID token signature verification failed: Invalid signature/)
      end
    end
  end
end
