module Helper
  class JwksDocumentCache
    attr_accessor :jwks_document, :ttl, :cached_at
    attr_reader :expires_at

    def set_expires_at(ttl)
      @ttl = ttl
      @cached_at = Time.now.to_i
      @expires_at = @cached_at + @ttl
    end

    def get_jwks_document
      return nil if expired?

      @jwks_document
    end

    def expired?
      return true if @expires_at.nil?

      Time.now.to_i >= @expires_at
    end
  end
end
