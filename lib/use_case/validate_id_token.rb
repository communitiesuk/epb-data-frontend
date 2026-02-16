module UseCase
  class ValidateIdToken
    def initialize(onelogin_gateway:, cache:)
      @onelogin_gateway = onelogin_gateway
      @cache = cache
    end

    def execute(token_response_hash:, nonce:, vtr: '["Cl.Cm"]')
      if @cache.jwks_document.nil? || @cache.expired?
        begin
          response = @onelogin_gateway.fetch_jwks_document
          domain = Domain::OneloginIdToken.new(response:, token_response_hash:, nonce:, vtr:)
          ttl = domain.extract_max_age_from_cache_control

          @cache.jwks_document = response
          @cache.set_expires_at(ttl)
        rescue Errors::NetworkError => e
          raise Errors::AuthenticationError, "Unable to fetch JWKS document and no cached document is available: #{e.message}" if @cache.jwks_document.nil?
        end
      end

      domain ||= Domain::OneloginIdToken.new(response: @cache.jwks_document, token_response_hash:, nonce:, vtr:)
      domain.fetch_matching_key
      domain.verify_signature(alg: ENV["ALG"])
      domain.validate_claims
    end
  end
end
