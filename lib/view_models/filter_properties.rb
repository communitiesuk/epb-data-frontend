module ViewModels
  class FilterProperties
    def self.page_title(property_type)
      case property_type
      when "domestic"
        I18n.t("filter_properties.domestic_title")
      when "non_domestic"
        I18n.t("filter_properties.non_domestic_title")
      when "public_buildings"
        I18n.t("filter_properties.dec_title")
      else
        ""
      end
    end

    def self.councils
      [
        "Select all",
        "Aberdeen City Council",
        "Aberdeenshire Council",
        "Angus Council",
      ]
    end

    def self.parliamentary_constituencies
      [
        "Select all",
        "Bristol Central",
        "Cities of London and Westminster",
        "Manchester Central",
      ]
    end

    def self.selected_area_type(params)
      if params["local-authority"] != "Select all"
        params["local-authority"]
      elsif params["parliamentary-constituency"] != "Select all"
        params["parliamentary-constituency"]
      elsif params["postcode"] != ""
        params["postcode"]
      else
        "England and Wales"
      end
    end

    def self.selected_eff_ratings(params)
      params["ratings"]&.join(", ")
    end

    def self.years
      (2012..Time.now.year).map(&:to_s)
    end

    def self.months
      I18n.t("date.months")
    end

    def self.start_year
      "2012"
    end

    def self.selected_start_and_end_dates(params)
      "#{params['from-month']} #{params['from-year']} - #{params['to-month']} #{params['to-year']}"
    end

    def self.current_year
      Date.today.year.to_s
    end

    def self.previous_month
      (Date.today << 1).strftime("%B")
    end

    def self.dates_from_inputs(year, month)
      Date.new(year.to_i, Date::MONTHNAMES.index(month) || 0)
    end

    def self.is_valid_date?(params)
      return true if params.empty?

      start_date = dates_from_inputs(params["from-year"], params["from-month"])
      end_date = dates_from_inputs(params["to-year"], params["to-month"])

      start_date < end_date
    end
  end
end
