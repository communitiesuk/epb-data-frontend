describe Gateway::CertificateCountGateway do
  include RSpecUnitMixin
  subject(:gateway) { described_class.new(get_api_client) }

  describe "#fetch" do
    let(:args) do
      {
        date_start: "2020-01-01",
        date_end: "2021-01-01",
        property_type: "domestic",
        council: %w[bedford],
        constituency: nil,
        postcode: nil,
        eff_rating: %w[A B],
      }
    end

    let(:response) { gateway.fetch(**args) }

    before do
      CertificateCountStub.fetch(date_start: args[:date_start], date_end: args[:date_end], property_type: args[:property_type], council: args[:council], eff_rating: args[:eff_rating])
    end

    it "return an integer" do
      expect(response).to eq(25)
    end

    context "when the postcode value is an empty string" do
      let(:args) do
        {
          date_start: "2020-01-01",
          date_end: "2021-01-01",
          property_type: "domestic",
          council: nil,
          constituency: nil,
          postcode: "",
          eff_rating: %w[A B],
        }
      end

      before do
        CertificateCountStub.fetch(date_start: args[:date_start], date_end: args[:date_end], property_type: args[:property_type], eff_rating: args[:eff_rating])
      end

      it "the postcode is not sent to the count api and returns an integer" do
        expect(response).to eq(25)
      end
    end
  end
end
