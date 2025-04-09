describe Gateway::CertificateCountGateway do
  include RSpecUnitMixin
  subject(:gateway) { described_class.new(get_api_client) }

  describe "#fetch" do
    let(:response) { gateway.fetch }

    before do
      CertificateCountStub.fetch
    end

    it "return an integer" do
      expect(response).to eq({ count: 25 })
    end
  end
end
