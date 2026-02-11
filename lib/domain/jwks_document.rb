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
      kid, alg = extract_kid_and_alg_from_id_token

      matching_key = find_matching_key_in_jwks(kid)
      raise Errors::AuthenticationError, "No matching key was found in the JWKS document for the kid" if matching_key.nil?

      alg_match = check_alg_match(jwks_document_key: matching_key, alg:)
      raise Errors::AuthenticationError, "The alg in the JWKS document does not match the algorithm (alg) in the ID token" unless alg_match

      verify_signature?(jwks_document_key: matching_key, alg:)
    end

    def verify_signature?(jwks_document_key:, alg:)
      jwk = JWT::JWK.import(jwks_document_key)

      JWT.decode(@id_token, jwk.public_key, true, { algorithm: alg })

      true
    rescue StandardError => e
      case e
      when JWT::DecodeError
        raise Errors::AuthenticationError, "ID token signature verification failed: #{e.message}"
      end
    end

  private

    def extract_kid_and_alg_from_id_token
      header_segment = @id_token.split(".").first
      decoded_header = Base64.urlsafe_decode64(header_segment)
      header = JSON.parse(decoded_header)

      kid = header["kid"]
      alg = header["alg"]

      [kid, alg]
    end

    def find_matching_key_in_jwks(kid)
      jwks_keys = @jwks_document["keys"]
      matching_key = jwks_keys.find { |key| key["kid"] == kid }

      if matching_key.nil?
        nil
      else
        matching_key
      end
    end

    def check_alg_match(jwks_document_key:, alg:)
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
