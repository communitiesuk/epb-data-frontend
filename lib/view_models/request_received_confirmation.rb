module ViewModels
  class RequestReceivedConfirmation < ViewModels::FilterProperties
    def self.selected_start_and_end_dates(params)
      "#{params['from-month']} #{params['from-year']} - #{params['to-month']} #{params['to-year']}"
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
  end
end
