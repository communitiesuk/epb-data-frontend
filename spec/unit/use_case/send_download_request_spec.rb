require_relative "../../../lib/errors"
describe UseCase::SendDownloadRequest do
  let(:sns_gateway) do
    instance_double(Gateway::SnsGateway)
  end

  let(:use_case) do
    described_class.new(sns_gateway:)
  end

  describe "#execute" do
    let(:use_case_args) do
      {
        date_start: "2023-01-01",
        date_end: "2023-01-31",
        email_address: "epbtest@mctesty.com",
        property_type: "domestic",
        area_type: "local_authority",
        area_value: %w[Aberdeen Angus],
        include_recommendations: true,
        efficiency_ratings: %w[A B C],
      }
    end

    let(:expected_gateway_args) do
      {
        area: {
          local_authority: %w[Aberdeen Angus],
        },
        date_end: "2023-01-31",
        date_start: "2023-01-01",
        efficiency_ratings: %w[A B C],
        email_address: "epbtest@mctesty.com",
        include_recommendations: true,
        property_type: "domestic",
      }
    end

    let(:test_topic_arn) do
      "arn:aws:sns:us-east-1:123456789012:testTopic"
    end

    before do
      allow(sns_gateway).to receive(:send_message)
      ENV["SEND_DOWNLOAD_TOPIC_ARN"] = test_topic_arn
    end

    after do
      ENV["SEND_DOWNLOAD_TOPIC_ARN"] = nil
    end

    it "calls the correct gateway method" do
      use_case.execute(**use_case_args)
      expect(sns_gateway).to have_received(:send_message).with(test_topic_arn, expected_gateway_args).exactly(1).times
    end

    it "handles invalid property_type arguments" do
      use_case_args.merge!(property_type: "invalid")
      expect { use_case.execute(**use_case_args) }.to raise_error(Errors::InvalidPropertyType)
    end
  end
end
