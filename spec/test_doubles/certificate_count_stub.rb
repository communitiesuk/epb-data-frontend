class CertificateCountStub
  def self.fetch(date_start:, date_end:, council: nil, constituency: nil, postcode: nil, return_count: 25, eff_rating: %w[A B C D E F G], timeout: false)
    query_string = "date_start=#{date_start}&date_end=#{date_end}"
    query_string += council.map { |c| "&council[]=#{c}" }.join.to_s unless council.nil?
    query_string += constituency.map { |c| "&constituency[]=#{c}" }.join.to_s unless constituency.nil?
    query_string += "&postcode=#{postcode}" unless postcode.nil?
    query_string += eff_rating.map { |c| "&eff_rating[]=#{c}" }.join.to_s unless eff_rating.nil?

    request = WebMock.stub_request(:get, "http://epb-data-warehouse-api/api/domestic/count?#{query_string}")

    if timeout
      request.to_timeout
    else
      body = { data: { count: return_count }, meta: {} }
      request.to_return(status: 200, body: body.to_json, headers: {})
    end
  end
end
