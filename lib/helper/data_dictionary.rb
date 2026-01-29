require "sinatra/base"

module Helper
  module DataDictionary
    DATA_DIR = File.expand_path(File.join(__dir__, "../../data")).freeze
    CONTENT_TYPE = "text/csv".freeze

    def download_data_dictionary_csv(property_type:)
      file_name = "#{property_type}_data_dictionary.csv"
      file_path = File.expand_path(File.join(DATA_DIR, file_name))

      raise Errors::FileNotFound unless File.exist?(file_path)

      send_file(
        file_path,
        filename: file_name,
        type: CONTENT_TYPE,
        disposition: "attachment",
        cache_control: :no_store,
      )
    end
  end
end
