describe UseCase::GetDownloadSize do
  let(:certificate_count_gateway) do
    instance_double(Gateway::CertificateCountGateway)
  end

  let(:use_case) do
    described_class.new(certificate_count_gateway:)
  end

  let(:invalid_use_case_args) do
    {
      date_start: "2023-01-01",
      date_end: "2023-01-31",
      council: "NotFoundCouncil",
      eff_rating: %w[A G],
    }
  end

  let(:use_case_args) do
    {
      date_start: "2023-01-01",
      date_end: "2023-01-31",
      council: %w[Manchester Birmingham],
      eff_rating: %w[A G],
    }
  end

  let(:expected_gateway_args) do
    use_case_args.merge({
      constituency: nil,
      postcode: nil,
    })
  end

  describe "#execute" do
    context "when the data for selected filters is found" do
      before do
        allow(certificate_count_gateway).to receive(:fetch).and_return(100)
      end

      it "calls the correct gateway method" do
        use_case.execute(**use_case_args)
        expect(certificate_count_gateway).to have_received(:fetch).with(expected_gateway_args).exactly(1).times
      end

      it "returns the correct count" do
        expect(use_case.execute(**use_case_args)).to eq(100)
      end

      it "does not raise any error" do
        expect { use_case.execute(**use_case_args) }.not_to raise_error
      end
    end

    context "when the data is not found for selected filters" do
      before do
        allow(certificate_count_gateway).to receive(:fetch).and_return(0)
      end

      it "raises a data not found error" do
        expect { use_case.execute(**invalid_use_case_args) }.to raise_error(Errors::FilteredDataNotFound)
      end
    end
  end
end
