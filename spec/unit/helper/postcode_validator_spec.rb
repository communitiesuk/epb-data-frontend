describe Helper::PostcodeValidator, type: :helper do
  context "when validating postcode with valid postcodes" do
    it "formats lowercase postcode correctly" do
      expect(described_class.validate("ec1a 1bb")).to eq("EC1A 1BB")
    end

    it "handles postcodes with no spaces" do
      expect(described_class.validate("w1a0ax")).to eq("W1A 0AX")
    end
  end

  context "when validating postcode with invalid postcodes" do
    it "raises PostcodeIncompleteError" do
      expect { described_class.validate("123") }.to raise_error(Errors::PostcodeIncomplete)
    end

    it "raises PostcodeWrongFormatError" do
      expect { described_class.validate("123AVE 32S&") }.to raise_error(Errors::PostcodeWrongFormat)
    end

    it "raises PostcodeNotValidError" do
      expect { described_class.validate("aaaaaa") }.to raise_error(Errors::PostcodeNotValid)
    end
  end
end
