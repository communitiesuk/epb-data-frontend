class CertificateCountStub
  def self.fetch(date_start:, date_end:, property_type:, council: nil, constituency: nil, postcode: nil, return_count: 25, eff_rating: %w[A B C D E F G])
    query_string = "date_start=#{date_start}&date_end=#{date_end}"
    query_string += council.map { |c| "&council[]=#{c}" }.join.to_s unless council.nil?
    query_string += constituency.map { |c| "&constituency[]=#{c}" }.join.to_s unless constituency.nil?
    query_string += "&postcode=#{postcode}" unless postcode.nil?
    query_string += eff_rating.map { |c| "&efficiency_rating[]=#{c}" }.join.to_s unless eff_rating.nil?
    body = { data: { count: return_count }, meta: {} }

    WebMock.stub_request(:get, "http://epb-data-warehouse-api/api/#{property_type}/count?#{query_string}").to_return(status: 200, body: body.to_json, headers: {})
  end

  def self.fetch_any
    body = { data: { count: 100 }, meta: {} }
    WebMock.stub_request(:get, /epb-data-warehouse-api/).to_return(status: 200, body: body.to_json, headers: {})
  end
end
