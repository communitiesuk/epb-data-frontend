module ViewModels
  class RequestReceivedConfirmation < ViewModels::FilterProperties
    def self.selected_start_and_end_dates(params)
      from_month, from_year = params.values_at("from-month", "from-year")
      to_month, to_year = params.values_at("to-month", "to-year")

      raise Errors::InvalidDateArgument unless ViewModels::FilterProperties.months.include?(from_month)
      raise Errors::InvalidDateArgument unless ViewModels::FilterProperties.months.include?(to_month)

      "#{from_month} #{from_year} - #{to_month} #{to_year}"
    end

    def self.format_bytes(number_bytes)
      bytes_on_mb = 1_000_000
      header_bytes = 1888
      avg_row_bytes = 980.21

      estimated_total_bytes = header_bytes + (number_bytes * avg_row_bytes)
      size_mb = (estimated_total_bytes / bytes_on_mb).round(2)

      whole, decimal = size_mb.to_s.split(".")
      whole = whole.reverse.scan(/\d{1,3}/).join(",").reverse
      [whole, decimal].compact.join(".")
    end

    def self.format_number(number)
      num_groups = number.to_s.chars.to_a.reverse.each_slice(3)
      num_groups.map(&:join).join(",").reverse
    end

    def self.selected_area_type(params)
      default_area = "England and Wales"
      case params["area-type"]
      when "local-authority"
        params["local-authority"] != ["Select all"] ? params["local-authority"].join(", ") : default_area
      when "parliamentary-constituency"
        params["parliamentary-constituency"] != ["Select all"] ? params["parliamentary-constituency"].join(", ") : default_area
      when "postcode"
        params["postcode"] != "" ? params["postcode"].upcase : default_area
      else
        default_area
      end
    end

    def self.selected_eff_ratings(params)
      params["ratings"]&.join(", ")
    end
  end
end
