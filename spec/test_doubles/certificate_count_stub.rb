class CertificateCountStub
  def self.fetch
    body = { count: 25 }

    WebMock
      .stub_request(
        :get,
        "http://epb-data-warehouse-api/api/domestic/count",
      )
      .to_return(status: 200, body: body.to_json)
  end
end
