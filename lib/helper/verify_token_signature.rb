module Helper
  class VerifyTokenSignature
    def self.get_payload(jwks_document_key:, alg:, id_token:)
      jwk = JWT::JWK.import(jwks_document_key)

      payload, _header = JWT.decode(id_token, jwk.public_key, true, { algorithm: alg, verify_expiration: true, verify_iat: true })

      payload
    rescue JWT::DecodeError => e
      raise Errors::ValidationError, "ID token signature verification failed: #{e.message}"
    rescue JWT::ExpiredSignature => e
      raise Errors::ValidationError, "ID token has expired: #{e.message}"
    end
  end
end
