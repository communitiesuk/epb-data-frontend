require "sinatra/base"

module Helper
  module Csv
    DATA_DIR = File.expand_path(File.join(__dir__, "../../data")).freeze
    CONTENT_TYPE = "text/csv".freeze

    def download_data_dictionary_csv(property_type:)
      file_name = "#{property_type}_data_dictionary.csv"
      file_path = File.expand_path(File.join(DATA_DIR, file_name))

      raise Errors::FileNotFound unless File.exist?(file_path)
      raise Errors::InvalidCsvKey.new("LMK_KEY", file_name) if Helper::Csv.include_lmk_key?(file_path: file_path)

      send_file(
        file_path,
        filename: file_name,
        type: CONTENT_TYPE,
        disposition: "attachment",
        cache_control: :no_store,
      )
    end

    def self.include_lmk_key?(file_path:)
      File.open(file_path, "r") do |file|
        header = file.readline
        headers = header.strip.split(",").map(&:strip)
        return headers.include?("LMK_KEY")
      end
    end
  end
end
