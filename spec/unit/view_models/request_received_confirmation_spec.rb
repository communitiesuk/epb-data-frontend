describe ViewModels::RequestReceivedConfirmation do
  let(:view_model) { described_class }

  describe "#selected_area_type" do
    context "when the the defaults are passed" do
      it "returns the England and Wales" do
        params = { "local-authority" => "Select all", "parliamentary-constituency" => "Select all", "postcode" => "" }
        expect(view_model.selected_area_type(params)).to eq "England and Wales"
      end
    end

    context "when filtered by a local authority" do
      it "returns the England and Wales" do
        params = { "local-authority" => "Angus Council", "parliamentary-constituency" => "Select all", "postcode" => "" }
        expect(view_model.selected_area_type(params)).to eq "Angus Council"
      end
    end

    context "when filtered by a postcode" do
      it "returns the England and Wales" do
        params = { "local-authority" => "Select all", "parliamentary-constituency" => "Select all", "postcode" => "SW1A 1AA" }
        expect(view_model.selected_area_type(params)).to eq "SW1A 1AA"
      end
    end
  end
end
