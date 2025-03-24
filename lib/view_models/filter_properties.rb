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
        "Aberdeen City Council",
        "Aberdeenshire Council",
        "Angus Council",
      ]
    end

    def self.parliamentary_constituencies
      [
        "Bristol Central",
        "Cities of London and Westminster",
        "Manchester Central",
      ]
    end

    def self.years
      (2012..2025).map(&:to_s)
    end

    def self.months
      I18n.t("date.months")
    end

    def self.start_year
      "2012"
    end

    def self.current_year
      Date.today.year.to_s
    end

    def self.previous_month
      (Date.today << 1).strftime("%B")
    end

    def self.is_valid_date(params)
      return true if params.empty?

      start_date = Date.new(params["from-year"].to_i, Date::MONTHNAMES.index(params["from-month"]) || 0)
      end_date = Date.new(params["to-year"].to_i, Date::MONTHNAMES.index(params["to-month"]) || 0)

      start_date < end_date
    end
  end
end
