class CertificateCountStub
  def self.fetch(date_start:, date_end:, council: nil, constituency: nil, postcode: nil, eff_rating: nil)
    query_string = "date_start=#{date_start}&date_end=#{date_end}"
    query_string += "&council=#{council.join(',')}" unless council.nil?
    query_string += "&constituency=#{constituency.join(',')}" unless constituency.nil?
    query_string += "&postcode=#{postcode}" unless postcode.nil?
    query_string += "&eff_rating=#{eff_rating.join(',')}" unless eff_rating.nil?

    body = { count: 25 }

    WebMock
      .stub_request(
        :get,
        "http://epb-data-warehouse-api/api/domestic/count?#{query_string}",
      )
      .to_return(status: 200, body: body.to_json)
  end
end
