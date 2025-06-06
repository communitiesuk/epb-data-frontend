describe Gateway::CertificateCountGateway do
  include RSpecUnitMixin
  subject(:gateway) { described_class.new(get_api_client) }

  describe "#fetch" do
    let(:args) do
      {
        date_start: "2020-01-01",
        date_end: "2021-01-01",
        council: %w[bedford],
        constituency: nil,
        postcode: nil,
        eff_rating: %w[A B],
      }
    end

    let(:response) { gateway.fetch(**args) }

    before do
      CertificateCountStub.fetch(date_start: args[:date_start], date_end: args[:date_end], council: args[:council], eff_rating: args[:eff_rating])
    end

    it "return an integer" do
      expect(response).to eq(25)
    end
  end
end
