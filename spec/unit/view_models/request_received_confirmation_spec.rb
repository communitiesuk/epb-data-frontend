describe ViewModels::RequestReceivedConfirmation do
  let(:view_model) { described_class }

  describe "#count_to_size" do
    context "when count is passed" do
      it "returns the estimated size" do
        count = 29_279
        expect(view_model.count_to_size(count)).to eq 28.70
      end
    end

    context "when count is 0" do
      it "returns the headers size" do
        count = 0
        expect(view_model.count_to_size(count)).to eq 0
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
