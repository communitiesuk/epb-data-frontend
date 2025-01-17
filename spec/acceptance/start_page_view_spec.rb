describe "Acceptance::Service start page", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/" do
    context "when the start page is rendered" do
      it "the title to be coreect" do
        expect(response.body).to have_css("h1", text: "Hello World")
      end
    end
  end
end
