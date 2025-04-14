require_relative "../../../lib/errors"
describe UseCase::GetDownloadSize do
  let(:certificate_count_gateway) do
    instance_double(Gateway::CertificateCountGateway)
  end

  let(:use_case) do
    described_class.new(certificate_count_gateway:)
  end

  describe "#execute" do
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

    before do
      allow(certificate_count_gateway).to receive(:fetch)
    end

    it "calls the correct gateway method" do
      use_case.execute(**use_case_args)
      expect(certificate_count_gateway).to have_received(:fetch).with(expected_gateway_args).exactly(1).times
    end
  end
end
