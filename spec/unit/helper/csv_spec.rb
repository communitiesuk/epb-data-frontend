describe Helper::Csv do
  describe "#download_data_dictionary_csv" do
    let(:property_type) { "domestic" }
    let(:file_name) { "#{property_type}_data_dictionary.csv" }
    let(:file_path) { "/fake/path/test_file.csv" }
    let(:content_type) { "text/csv" }

    let(:helper_context) do
      Class.new {
        include Helper::Csv
        def send_file(*); end
      }.new
    end

    before do
      allow(File).to receive(:expand_path).and_return(file_path)
    end

    context "when the file exists" do
      before do
        allow(File).to receive(:exist?).with(file_path).and_return(true)
        allow(described_class).to receive(:include_lmk_key?).with(file_path: file_path).and_return(false)
      end

      it "calls send_file with correct parameters" do
        expect(helper_context).to receive(:send_file).with(
          file_path,
          filename: file_name,
          type: Helper::Csv::CONTENT_TYPE,
          disposition: "attachment",
          cache_control: :no_store,
        )

        helper_context.download_data_dictionary_csv(property_type: property_type)
      end
    end

    context "when the file does not exist" do
      before do
        allow(File).to receive(:exist?).with(file_path).and_return(false)
      end

      it "raises Errors::FileNotFound" do
        expect { helper_context.download_data_dictionary_csv(property_type: property_type) }.to raise_error(Errors::FileNotFound)
      end
    end

    context "when the file exists but includes LMK_KEY" do
      before do
        allow(File).to receive(:exist?).with(file_path).and_return(true)
        allow(described_class).to receive(:include_lmk_key?).with(file_path: file_path).and_return(true)
      end

      it "raises Errors::InvalidCsvKey" do
        expect { helper_context.download_data_dictionary_csv(property_type: property_type) }.to raise_error(Errors::InvalidCsvKey, /Invalid key: 'LMK_KEY' in the the domestic_data_dictionary.csv/)
      end
    end
  end
end
