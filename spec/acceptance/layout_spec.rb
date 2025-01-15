# frozen_string_literal: true

describe "Acceptance::AccessibilityStatement", type: :feature do
  include RSpecFrontendServiceMixin


  describe "get .find-energy-certificate-data.epb-frontend" do
    context "when the home page is rendered" do
      let(:response) { get "http://epc-data.local.gov.uk" }

      it "tab value is the same as the main header value" do
        expect(response.body).to include(
          "<title>Find an energy certificate – Find an energy certificate – GOV.UK</title>",
        )
      end

      it "includes the gov header" do
        expect(response.body).to have_link "Find an energy certificate"
      end

      it "does not allow indexing or following by crawlers" do
        expect(response.body).to include("<meta name=\"robots\" content=\"noindex, nofollow\">")
      end
    end
  end

  describe "non start pages" do
    let(:response) { get "http://find-energy-certificate.local.gov.uk/find-a-certificate/type-of-property" }

    it "does not allow indexing or following by crawlers" do
      expect(response.body).to include("<meta name=\"robots\" content=\"noindex, nofollow\">")
    end
  end
end
