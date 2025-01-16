describe "Acceptance::Service start page", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host){
    "http://find-energy-performance-data"
  }

  let(:response) { get local_host }

  describe "get .find-energy-certificate-data.epb-frontend/" do
    context "when the start page is rendered" do
      it "the title to be coreect" do
        expect(response.body).to have_css("h1", text: "Hello World")
      end
    end
  end

end
