describe ViewModels::FilterProperties do
  let(:view_model) { described_class }

  describe "#page_title" do
    let(:expected_titles) do
      ["Domestic Energy Performance Certificates",
       "Non-domestic Energy Performance Certificates",
       "Display Energy Certificates"]
    end

    it "returns the correct title for domestic, non-domestic and public properties" do
      property_types = %w[domestic non_domestic public_buildings]
      property_types.each_with_index do |property_type, index|
        expect(view_model.page_title(property_type)).to eq(expected_titles[index])
      end
    end
  end

  describe "#years" do
    before do
      Timecop.freeze(Time.utc(2026, 5, 4))
    end

    after do
      Timecop.return
    end

    context "when returning a list of years" do
      it "the first will be 2012" do
        expect(view_model.years.first).to eq "2012"
      end

      it "the last will be the current year" do
        expect(view_model.years.last).to eq "2026"
      end
    end
  end

  describe "#months" do
    it "returns the correct list of months" do
      expected_months = %w[January February March April May June July August September October November December]
      expect(view_model.months).to eq(expected_months)
    end
  end

  describe "#councils" do
    it "returns the correct list of councils" do
      expected_councils = [
        "Aberafan Maesteg",
        "Barnsley",
        "Nottingham",
      ]
      expect(view_model.councils).to include(*expected_councils)
    end

    it "returns 349 councills" do
      expect(view_model.councils.length).to eq 349
    end
  end

  describe "#parliamentary_constituencies" do
    it "returns the correct list of parliamentary constituencies" do
      expected_parliamentary_constituencies = [
        "Bristol Central",
        "Cities of London and Westminster",
        "Manchester Central",
      ]
      expect(view_model.parliamentary_constituencies).to include(*expected_parliamentary_constituencies)
    end

    it "returns 597 rows" do
      expect(view_model.parliamentary_constituencies.length).to eq 597
    end
  end

  describe "#previous_month" do
    before do
      Timecop.freeze(Time.utc(2026, 6, 1))
    end

    after do
      Timecop.return
    end

    context "when the current month is June" do
      it "returns May" do
        expect(view_model.previous_month).to eq("May")
      end
    end
  end

  describe "#start_date_from_inputs" do
    context "when the month from input is valid" do
      it "does not raise any errors" do
        params = { "from-year" => "2012", "from-month" => "January" }

        expect { view_model.start_date_from_inputs(params["from-year"], params["from-month"]) }.not_to raise_error
      end
    end

    context "when the month from input is invalid" do
      it "raises an error" do
        params = { "from-year" => "2012", "from-month" => "Jaary" }

        expect { view_model.start_date_from_inputs(params["from-year"], params["from-month"]) }.to raise_error(Errors::InvalidDateArgument)
      end
    end
  end

  describe "#end_date_from_inputs" do
    context "when the month from input is valid" do
      it "does not raise any errors" do
        params = { "to-year" => "2016", "to-month" => "May" }

        expect { view_model.end_date_from_inputs(params["to-year"], params["to-month"]) }.not_to raise_error
      end
    end

    context "when the month from input is invalid" do
      it "raises an error" do
        params = { "to-year" => "2016", "to-month" => "M" }

        expect { view_model.end_date_from_inputs(params["to-year"], params["to-month"]) }.to raise_error(Errors::InvalidDateArgument)
      end
    end
  end

  describe "#is_valid_date?" do
    before do
      Timecop.freeze(Time.utc(2025, 6, 15))
    end

    after do
      Timecop.return
    end

    context "when the valid dates are passed?" do
      it "return true" do
        params = { "from-year" => "2012", "from-month" => "January", "to-year" => "2024", "to-month" => "December" }

        expect(view_model.is_valid_date?(params)).to be(true)
      end
    end

    context "when invalid dates are passed" do
      it "return false" do
        params = { "from-year" => "2024", "from-month" => "April", "to-year" => "2024", "to-month" => "March" }

        expect(view_model.is_valid_date?(params)).to be(false)
      end
    end
  end
end
