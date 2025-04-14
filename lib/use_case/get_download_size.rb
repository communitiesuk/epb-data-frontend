module UseCase
  class GetDownloadSize
    def initialize(certificate_count_gateway:)
      @certificate_count_gateway = certificate_count_gateway
    end

    def execute(date_start:, date_end:, council: nil, constituency: nil, postcode: nil, eff_rating: nil)
      @certificate_count_gateway.fetch(date_start:, date_end:, council:, constituency:, postcode:, eff_rating:)
    end
  end
end
