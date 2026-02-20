module Domain
  class OneloginIdToken
    def initialize(response:, token_response_hash:, nonce:, vtr:)
      @response = response
      @jwks_document = response[:jwks]
      @id_token = token_response_hash.transform_keys(&:to_sym)[:id_token]
      @nonce = nonce
      @vtr = vtr
    end

    def extract_max_age_from_cache_control
      cache_control = @response[:cache_control]
      return nil unless cache_control

      seconds = cache_control.match(/max-age=(\d+)/)
      seconds ? seconds[1].to_i : nil
    end

    def fetch_matching_key
      kid, alg = extract_kid_and_alg_from_id_token

      @matching_key = find_matching_key_in_jwks(kid)
      raise Errors::ValidationError, "No matching key was found in the JWKS document for the kid" if @matching_key.nil?

      alg_match = check_alg_match(alg:)
      raise Errors::ValidationError, "The alg in the JWKS document does not match the algorithm (alg) in the ID token" unless alg_match

      @matching_key
    end

    def verify_signature
      jwk = JWT::JWK.import(@matching_key)

      @payload, _header = JWT.decode(@id_token, jwk.public_key, true, { algorithm: @matching_key["alg"], verify_expiration: true, verify_iat: true })

      @payload
    rescue JWT::ExpiredSignature => e
      raise Errors::ValidationError, "ID token has expired: #{e.message}"
    rescue JWT::DecodeError => e
      raise Errors::ValidationError, "ID token signature verification failed: #{e.message}"
    end

    def validate_claims
      unless valid_issuer?
        raise Errors::ValidationError, "Invalid id token issuer"
      end

      unless valid_audience?
        raise Errors::ValidationError, "Invalid id token audience"
      end

      unless valid_nonce?
        raise Errors::ValidationError, "Invalid id token nonce"
      end

      unless vtr_includes_vot?
        raise Errors::ValidationError, "The vtr in the login authorize request does not include the vot in the id token payload"
      end

      true
    end

  private

    def extract_kid_and_alg_from_id_token
      _payload, header = JWT.decode(@id_token, nil, false)
      kid = header["kid"]
      alg = header["alg"]

      [kid, alg]
    end

    def find_matching_key_in_jwks(kid)
      @jwks_document["keys"].find { |key| key["kid"] == kid }
    end

    def check_alg_match(alg:)
      if @matching_key.nil?
        return false
      end

      @matching_key["alg"] == alg
    end

    def valid_issuer?
      expected_issuer = ENV["ONELOGIN_HOST_URL"]
      expected_issuer == @payload["iss"].to_s.sub(%r{/\z}, "")
    end

    def valid_audience?
      expected_aud = ENV["ONELOGIN_CLIENT_ID"]
      expected_aud == @payload["aud"].to_s
    end

    def valid_nonce?
      @nonce == @payload["nonce"].to_s
    end

    def vtr_includes_vot?
      vtr = JSON.parse(@vtr).first
      vtr.include?(@payload["vot"].to_s)
    end
  end
end
