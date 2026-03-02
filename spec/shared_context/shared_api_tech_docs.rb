shared_context "when viewing api tech docs" do
  def page_urls
    %w[ making-a-request
        search-certificates/domestic
        search-certificates/non-domestic
        search-certificates/display
        search-certificates-changed
        download/domestic/csv
        download-info/domestic/csv
        download/domestic/json
        download-info/domestic/json
        download-info/non-domestic/csv
        download/non-domestic/json
        download-info/non-domestic/json
        download/non-domestic-recommendation/json
        download-info/non-domestic-recommendations/json
        download/display/csv
        download-info/display/csv
        download/display/json
        download-info/display/json
        download/display-recommendation/json
        download-info/display-recommendations/json
        codes
        codes-info]
  end

  def page_titles = [
    "Making a request",
    "Search for domestic certificates",
    "Search for non domestic certificates",
    "Search for display certificates",
    "Search for certificates that have changed",
    "Download domestic full load csv",
    "Fetch information about domestic full load csv",
    "Download domestic full load json",
    "Fetch information about domestic full load json",
    "Fetch information about non domestic full load csv",
    "Download non domestic full load json",
    "Fetch information about non domestic full load json",
    "Download non domestic recommendation full load json",
    "Fetch information about non domestic recommendations full load json",
    "Download display full load csv",
    "Fetch information about display full load csv",
    "Download display full load json",
    "Fetch information about display full load json",
    "Download display recommendation full load json",
    "Fetch information about display recommendations full load json",
    "Fetch EPC codes",
    "Fetch EPC codes information",
  ]

  def end_points
    page_urls.excluding ["making-a-request"]
  end

  def end_points_params
    page_urls.select { |i| i.start_with? "codes-", "search" }
  end
end
