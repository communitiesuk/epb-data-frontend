describe ViewModels::RequestReceivedConfirmation do
  let(:view_model) { described_class }

  describe "#get_formatted_byte_size" do
    let(:property_type) { "domestic" }
    let(:session) { {} }

    before do
      allow(Helper::Session).to receive(:get_session_value)
                                  .with(session, :download_count)
                                  .and_return(download_count)
    end

    context "when the download count is passed" do
      let(:download_count) { 29_279 }

      it "returns the estimated MB size" do
        expect(view_model.get_formatted_byte_size(download_count, property_type)).to eq "28.7 MB"
      end
    end

    context "when the download count is 0" do
      let(:download_count) { 0 }

      it "returns only the header size" do
        expect(view_model.get_formatted_byte_size(download_count, property_type)).to eq "1.89 kB"
      end
    end

    context "when the download count is greater than a million" do
      let(:download_count) { 25_100_279 }

      it "returns the estimated GB size" do
        expect(view_model.get_formatted_byte_size(download_count, property_type)).to eq "24.6 GB"
      end
    end

    context "when the download count is greater than a billion" do
      let(:download_count) { 4_500_002_790 }

      it "returns the estimated TB size" do
        expect(view_model.get_formatted_byte_size(download_count, property_type)).to eq "4.41 TB"
      end
    end
  end

  describe "#format_number_with_commas" do
    context "when count is less than 999" do
      it "returns correct formatted count" do
        count = 900
        expect(view_model.format_number_with_commas(count)).to eq "900"
      end
    end

    context "when count is more than 999" do
      it "returns the headers size" do
        count = 1000
        expect(view_model.format_number_with_commas(count)).to eq "1,000"
      end
    end

    context "when count is million" do
      it "returns the headers size" do
        count = 1_000_000
        expect(view_model.format_number_with_commas(count)).to eq "1,000,000"
      end
    end
  end

  describe "#get_formatted_download_count" do
    before do
      allow(view_model).to receive(:format_number_with_commas).and_call_original
    end

    context "when the download count is passed" do
      it "returns correct formatted count for numbers greater than 999" do
        download_count = 29_279
        expect(view_model.get_formatted_download_count(download_count)).to eq "29,279"
      end

      it "returns correct formatted count for numbers less than 999" do
        download_count = 900
        expect(view_model.get_formatted_download_count(download_count)).to eq "900"
      end
    end
  end

  describe "#selected_area_type" do
    context "when the the defaults are passed" do
      it "returns the England and Wales" do
        params = { "local-authority" => ["Select all"], "parliamentary-constituency" => ["Select all"], "postcode" => "" }
        expect(view_model.selected_area_type(params)).to eq "England and Wales"
      end
    end

    context "when filtered by a local authority" do
      it "returns correct council" do
        params = { "area-type" => "local-authority", "local-authority" => ["Angus Council"], "parliamentary-constituency" => ["Select all"], "postcode" => "" }
        expect(view_model.selected_area_type(params)).to eq "Angus Council"
      end
    end

    context "when filtered by a parliamentary constituency" do
      it "returns the correct constituency" do
        params = { "area-type" => "parliamentary-constituency", "local-authority" => ["Select all"], "parliamentary-constituency" => %w[Ashford], "postcode" => "" }
        expect(view_model.selected_area_type(params)).to eq "Ashford"
      end
    end

    context "when filtered by a postcode" do
      it "returns correct postcode" do
        params = { "area-type" => "postcode", "local-authority" => ["Select all"], "parliamentary-constituency" => ["Select all"], "postcode" => "SW1A 1AA" }
        expect(view_model.selected_area_type(params)).to eq "SW1A 1AA"
      end
    end
  end

  describe "#selected_start_and_end_dates" do
    context "when the months from inputs are valid" do
      params = { "from-year" => "2012", "from-month" => "January", "to-year" => "2024", "to-month" => "December" }

      it "returns a correct date" do
        expect(view_model.selected_start_and_end_dates(params)).to eq("January 2012 - December 2024")
      end

      it "does not raise any errors" do
        expect { view_model.selected_start_and_end_dates(params) }.not_to raise_error
      end
    end

    context "when the month from input is invalid" do
      params = { "from-year" => "2012", "from-month" => "Janry", "to-year" => "2024", "to-month" => "December" }
      it "raises an error" do
        expect { view_model.selected_start_and_end_dates(params) }.to raise_error(Errors::InvalidDateArgument)
      end
    end

    context "when the month from input is nil" do
      params = { "from-year" => "2012", "from-month" => "", "to-year" => "2024", "to-month" => "December" }
      it "raises an error" do
        expect { view_model.selected_start_and_end_dates(params) }.to raise_error(Errors::InvalidDateArgument)
      end
    end
  end
end
