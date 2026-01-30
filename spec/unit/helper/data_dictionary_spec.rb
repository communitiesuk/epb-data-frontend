shared_context "when identifying lmk_key in the data dictionary csv file" do
  def include_lmk_key?(file_path:)
    File.open(file_path, "r") do |file|
      header = file.readline
      headers = header.strip.split(",").map(&:strip)
      headers.include?("LMK_KEY")
    end
  end
end

describe Helper::DataDictionary do
  describe "#download_data_dictionary_csv" do
    include_context "when identifying lmk_key in the data dictionary csv file"

    let(:property_type) { "domestic" }
    let(:test_file_name) { "#{property_type}_data_dictionary.csv" }
    let(:test_file_path) { "/fake/path/test_file.csv" }
    let(:content_type) { "text/csv" }

    let(:helper_class) do
      Class.new {
        include Helper::DataDictionary
        def send_file(*); end
      }.new
    end

    before do
      allow(File).to receive(:expand_path).and_return(test_file_path)
    end

    context "when the file exists" do
      before do
        allow(File).to receive(:exist?).with(test_file_path).and_return(true)
      end

      it "calls send_file with correct parameters" do
        expect(helper_class).to receive(:send_file).with(
          test_file_path,
          filename: test_file_name,
          type: Helper::DataDictionary::CONTENT_TYPE,
          disposition: "attachment",
          cache_control: :no_store,
        )

        helper_class.download_data_dictionary_csv(property_type: property_type)
      end
    end

    context "when the file exists, but has LMK_KEY" do
      before do
        allow(File).to receive(:expand_path).and_call_original
      end

      it "verifies that all data dictionary CSV files does not include LMK_KEY column" do
        allow(File).to receive(:expand_path).and_call_original

        %w[domestic non_domestic display].each do |property_type|
          file = "#{property_type}_data_dictionary.csv"
          path = File.expand_path(File.join(Helper::DataDictionary::DATA_DIR, file))
          expect(include_lmk_key?(file_path: path)).to be(false)
        end
      end
    end

    context "when the file does not exist" do
      before do
        allow(File).to receive(:exist?).with(test_file_path).and_return(false)
      end

      it "raises Errors::FileNotFound" do
        expect { helper_class.download_data_dictionary_csv(property_type: property_type) }.to raise_error(Errors::FileNotFound)
      end
    end
  end
end
