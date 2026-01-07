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

  def end_points
    page_urls.excluding ["making-a-request"]
  end

  def end_points_params
    page_urls.select { |i| i.start_with? "codes-", "search" }
  end
end
