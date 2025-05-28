# frozen_string_literal: true

describe "Acceptance::Layout", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data"
  end

  describe "get .get-energy-certificate-data.epb-frontend" do
    context "when the home page is rendered" do
      let(:response) { get local_host }

      it "tab value is the same as the main header value" do
        expect(response.body).to include(
          "<title>Get energy performance of buildings data – GOV.UK</title>",
        )
      end

      it "includes the gov header" do
        expect(response.body).to have_link "Get energy performance of buildings data"
      end

      it "has a link in the footer for the cookies page" do
        expect(response.body).to have_css("footer ul.govuk-footer__inline-list a", text: "Cookies")
        expect(response.body).to have_link("Cookies", href: "/cookies")
      end

      it "does not allow indexing or following by crawlers" do
        expect(response.body).to include('<meta name="robots" content="noindex, nofollow">')
      end
    end
  end
end
