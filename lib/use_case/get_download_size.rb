module UseCase
  class GetDownloadSize
    def initialize(certificate_count_gateway:)
      @certificate_count_gateway = certificate_count_gateway
    end

    def execute(date_start:, date_end:, council: nil, constituency: nil, postcode: nil, eff_rating: nil)
      results_count = @certificate_count_gateway.fetch(
        date_start: date_start,
        date_end: date_end,
        council: council,
        constituency: constituency,
        postcode: postcode,
        eff_rating: eff_rating,
      )
      raise Errors::FilteredDataNotFound if results_count.zero?

      results_count
    end
  end
end
