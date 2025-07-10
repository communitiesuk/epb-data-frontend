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

      it "does not allow indexing or following by crawlers" do
        expect(response.body).to include('<meta name="robots" content="noindex, nofollow">')
      end

      it "does not display the sign out button" do
        expect(response.body).not_to have_link("Sign out", href: "sign-out")
      end

      context "when a user is signed in" do
        before do
          allow(Helper::Session).to receive(:is_logged_in?).and_return(true)
        end

        it "displays the sign out button" do
          expect(response.body).to have_link("Sign out", href: "/sign-out")
        end
      end
    end
  end
end
