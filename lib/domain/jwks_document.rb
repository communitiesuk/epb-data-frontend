module Domain
  class JwksDocument
    def initialize(response:, token_response_hash:)
      @response = response
      @jwks_document = response[:jwks]
      @id_token = token_response_hash.transform_keys(&:to_sym)[:id_token]
    end

    def extract_max_age_from_cache_control
      cache_control = @response[:cache_control]
      return nil unless cache_control

      seconds = cache_control.match(/max-age=(\d+)/)
      seconds ? seconds[1].to_i : nil
    end

    def validate_id_token
      matching_key = check_kid_match
      raise Errors::AuthenticationError, "No matching key was found in the JWKS document for the kid" if matching_key.nil?

      check_alg_match(jwks_document_key: matching_key)
    end

  private

    def check_kid_match
      tls_keys = ENV["ONELOGIN_TLS_KEYS"]
      kid = Helper::Onelogin.extract_kid(tls_keys)

      jwks_keys = @jwks_document["keys"]
      matching_key = jwks_keys.find { |key| key["kid"] == kid }

      if matching_key.nil?
        nil
      else
        matching_key
      end
    end

    def check_alg_match(jwks_document_key:)
      alg = ENV["ALG"]

      if jwks_document_key.nil?
        return false
      end

      match = jwks_document_key["alg"] == alg

      if match
        true
      else
        false
      end
    end
  end
end
