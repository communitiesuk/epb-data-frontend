require "bytesize"

module ViewModels
  class RequestReceivedConfirmation < ViewModels::FilterProperties
    HEADER_ROW_SIZE_BYTES = 1888
    AVG_DOMESTIC_ROW_SIZE_BYTES = 980.21
    AVG_NON_DOMESTIC_ROW_SIZE_BYTES = 392.0
    AVG_DEC_ROW_SIZE_BYTES = 351.5

    def self.get_formatted_byte_size(download_count, property_type)
      avg_row_bytes = case property_type
                      when "domestic"
                        AVG_DOMESTIC_ROW_SIZE_BYTES
                      when "non-domestic"
                        AVG_NON_DOMESTIC_ROW_SIZE_BYTES
                      else
                        AVG_DEC_ROW_SIZE_BYTES
                      end
      total_bytes_estimate = HEADER_ROW_SIZE_BYTES + (download_count * avg_row_bytes)

      ByteSize.new(total_bytes_estimate.round).to_s
    end

    def self.format_number_with_commas(number)
      num_groups = number.to_s.chars.to_a.reverse.each_slice(3)
      num_groups.map(&:join).join(",").reverse
    end

    def self.get_formatted_download_count(download_count)
      format_number_with_commas(download_count)
    end

    def self.selected_start_and_end_dates(params)
      from_month, from_year = params.values_at("from-month", "from-year")
      to_month, to_year = params.values_at("to-month", "to-year")

      raise Errors::InvalidDateArgument unless ViewModels::FilterProperties.months.include?(from_month)
      raise Errors::InvalidDateArgument unless ViewModels::FilterProperties.months.include?(to_month)

      "#{from_month} #{from_year} - #{to_month} #{to_year}"
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
