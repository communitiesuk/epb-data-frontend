module ViewModels
  class RequestReceivedConfirmation < ViewModels::FilterProperties
    def self.selected_start_and_end_dates(params)
      from_month, from_year = params.values_at("from-month", "from-year")
      to_month, to_year = params.values_at("to-month", "to-year")

      raise Errors::InvalidDateArgument unless ViewModels::FilterProperties.months.include?(from_month)
      raise Errors::InvalidDateArgument unless ViewModels::FilterProperties.months.include?(to_month)

      "#{from_month} #{from_year} - #{to_month} #{to_year}"
    end

    def self.count_to_size(count)
      bytes_on_mb = 1_000_000
      header_bytes = 1888
      avg_row_bytes = 980.21
      estimated_total_bytes = header_bytes + (count * avg_row_bytes)
      (estimated_total_bytes / bytes_on_mb).round(2)
    end

    def self.selected_area_type(params)
      if params["local-authority"] != ["Select all"]
        params["local-authority"].join(", ")
      elsif params["parliamentary-constituency"] != ["Select all"]
        params["parliamentary-constituency"].join(", ")
      elsif params["postcode"] != "" && !params["postcode"].nil?
        params["postcode"].upcase
      else
        "England and Wales"
      end
    end

    def self.selected_eff_ratings(params)
      params["ratings"]&.join(", ")
    end
  end
end
