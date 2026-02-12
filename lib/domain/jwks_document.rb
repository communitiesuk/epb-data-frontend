module Domain
  class JwksDocument
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

    def validate_id_token?
      kid, alg = extract_kid_and_alg_from_id_token

      matching_key = find_matching_key_in_jwks(kid)
      raise Errors::AuthenticationError, "No matching key was found in the JWKS document for the kid" if matching_key.nil?

      alg_match = check_alg_match(jwks_document_key: matching_key, alg:)
      raise Errors::AuthenticationError, "The alg in the JWKS document does not match the algorithm (alg) in the ID token" unless alg_match

      @payload = Helper::VerifyTokenSignature.get_payload(jwks_document_key: matching_key, alg:, id_token: @id_token)

      unless valid_issuer?
        raise Errors::AuthenticationError, "Invalid id token issuer"
      end

      unless valid_audience?
        raise Errors::AuthenticationError, "Invalid id token audience"
      end

      unless valid_nonce?
        raise Errors::AuthenticationError, "Invalid id token nonce"
      end

      unless vtr_includes_vot?
        raise Errors::AuthenticationError, "The vtr in the login authorize request does not include the vot in the id token payload"
      end

      true
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
      @jwks_document["keys"].find { |key| key["kid"] == kid }
    end

    def check_alg_match(jwks_document_key:, alg:)
      if jwks_document_key.nil?
        return false
      end

      jwks_document_key["alg"] == alg
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
