describe Helper::JwksDocumentCache do
  subject(:cache) { described_class.new }

  let(:jwks_document) { { keys: [{ "kid": "test-key-id", "kty": "RSA", "use": "sig", "n": "test", "alg": "RS256", "e": "AQAB" }] } }
  let(:ttl) { 86_400 }
  let(:current_time) { Time.utc(2026, 1, 1, 0, 0, 0) }

  describe "#set_expires_at" do
    around do |example|
      Timecop.freeze(current_time) { example.run }
    end

    let(:expected_expires_at) { current_time.to_i + ttl }

    it "sets the cached_at and expires_at correctly" do
      cache.set_expires_at(ttl)

      expect(cache.cached_at).to eq(current_time.to_i)
      expect(cache.expires_at).to eq(current_time.to_i + ttl)
    end
  end

  describe "#expired?" do
    context "when expires_at is nil" do
      it "returns true" do
        expect(cache.expired?).to be true
      end
    end

    context "when expires_at is in the past" do
      around do |example|
        Timecop.freeze(current_time) do
          cache.jwks_document = jwks_document
          cache.set_expires_at(ttl)

          Timecop.travel(current_time + ttl + 1) { example.run }
        end
      end

      it "returns true" do
        expect(cache.expired?).to be true
      end
    end

    context "when expires_at is in the future" do
      around do |example|
        Timecop.freeze(current_time) do
          cache.jwks_document = jwks_document
          cache.set_expires_at(ttl)

          Timecop.travel(current_time + ttl - 1) { example.run }
        end
      end

      it "returns false" do
        expect(cache.expired?).to be false
      end
    end
  end
end
