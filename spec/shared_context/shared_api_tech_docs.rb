shared_context "when viewing api tech docs" do
  def page_urls
    %w[ making-a-request
        fetch-certificate-data
        search-certificates
        search-certificates-changed
        download/domestic
        download/non-domestic-recommendations
        codes
        codes-info]
  end

  def page_titles = [
    "Making a request",
    "Fetch certificate data",
    "Search certificates",
    "Search for certificates that have changed",
    "Download domestic, non-domestic and display files",
    "Download non-domestic and display recommendations files",
    "Fetch EPC codes",
    "Fetch EPC codes information",
  ]

  def end_points
    page_urls.excluding ["making-a-request"]
  end

  def end_points_params
    page_urls.select { |i| i.start_with? "codes-", "search" }
  end

  def redirected_urls
    {
      "search-certificates/domestic" => "/api-technical-documentation/search-certificates#domestic",
      "search-certificates/non-domestic" => "/api-technical-documentation/search-certificates#non-domestic",
      "search-certificates/display" => "/api-technical-documentation/search-certificates#display",
      "deltas" => "/api-technical-documentation/search-certificates-changed",
      "download/non-domestic" => "/api-technical-documentation/download/domestic",
      "download/display" => "/api-technical-documentation/download/domestic",
      "download/display-recommendations" => "/api-technical-documentation/download/non-domestic-recommendations",
      "download/domestic/csv" => "/api-technical-documentation/download/domestic#csv-download",
      "download-info/domestic/csv" => "/api-technical-documentation/download/domestic#csv-info",
      "download/non-domestic/json" => "/api-technical-documentation/download/domestic#json-download",
      "download/display/json" => "/api-technical-documentation/download/domestic#json-download",
      "download/non-domestic-recommendation/json" => "/api-technical-documentation/download/non-domestic-recommendations#json-download",
      "download-info/display-recommendations/json" => "/api-technical-documentation/download/non-domestic-recommendations#json-info",
    }
  end
end

