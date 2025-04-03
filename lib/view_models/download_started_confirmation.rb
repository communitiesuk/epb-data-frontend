module ViewModels
  class DownloadStartedConfirmation < ViewModels::FilterProperties
    def self.default_end_date
      "January #{start_year} - #{previous_month} #{current_year}"
    end
  end
end
