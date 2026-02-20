module UseCase
  class GetDownloadSize
    def initialize(certificate_count_gateway:)
      @certificate_count_gateway = certificate_count_gateway
    end

    def execute(date_start:, date_end:, property_type:, council: nil, constituency: nil, postcode: nil, eff_rating: nil)
      @certificate_count_gateway.fetch(
        date_start: date_start,
        date_end: date_end,
        property_type: property_type,
        council: council,
        constituency: constituency,
        postcode: postcode,
        eff_rating: eff_rating,
      )
    end
  end
end
