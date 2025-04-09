module Gateway
  class CertificateCountGateway
    def initialize(api_client)
      @internal_api_client = api_client
    end

    def fetch(date_start:, date_end:, council: nil, constituency: nil, postcode: nil, eff_rating: nil)
      query_string = "date_start=#{date_start}&date_end=#{date_end}"
      query_string += "&council=#{council.join(',')}" unless council.nil?
      query_string += "&constituency=#{constituency.join(',')}" unless constituency.nil?
      query_string += "&postcode=#{postcode}" unless postcode.nil?
      query_string += "&eff_rating=#{eff_rating.join(',')}" unless eff_rating.nil?
      route = "/api/domestic/count?#{query_string}"

      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
