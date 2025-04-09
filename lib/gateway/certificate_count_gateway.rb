module Gateway
  class CertificateCountGateway
    def initialize(api_client)
      @internal_api_client = api_client
    end

    def fetch
      route = "/api/domestic/count"
      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
