module Gateway
  class CertificateCountGateway
    def initialize(api_client)
      @internal_api_client = api_client
    end

    def fetch(date_start:, date_end:, council: nil, constituency: nil, postcode: nil, eff_rating: nil)
      query_string = "date_start=#{date_start}&date_end=#{date_end}"
      query_string += council.map { |c| "&council[]=#{c}" }.join.to_s unless council.nil?
      query_string += constituency.map { |c| "&constituency[]=#{c}" }.join.to_s unless constituency.nil?
      query_string += "&postcode=#{postcode}" unless postcode.nil?
      query_string += eff_rating.map { |c| "&eff_rating[]=#{c}" }.join.to_s unless eff_rating.nil?
      route = "/api/domestic/count?#{query_string}"
      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }
      response_json = JSON.parse(response.body, symbolize_names: true)
      response_json[:data][:count]
    end
  end
end
