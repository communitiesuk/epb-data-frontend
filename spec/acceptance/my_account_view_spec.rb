describe "Acceptance::MyAccount", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/api/my-account"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/api/my-account" do
    context "when the my account page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "has the correct page title" do
        expect(response.body).to have_css("h1", text: "My account")
      end

      it "shows the email address table row" do
        expect(response.body).to have_css("#email-address.govuk-summary-list__row")
      end

      it "shows the bearer token table row" do
        expect(response.body).to have_css("#bearer-token.govuk-summary-list__row")
      end

      it "shows the sign out link on email table row" do
        expect(response.body).to have_css("#email-sign-out.govuk-link")
        expect(response.body).to have_link("Sign out", href: "/sign-out")
      end

      it "shows the copy link on bearer token table row" do
        expect(response.body).to have_link("Copy", href: "#")
      end
    end

    context "when a user is signed in" do
      before do
        allow(Helper::Session).to receive(:is_logged_in?).and_return(true)
      end

      it "displays the sign out button" do
        expect(response.body).to have_css("#sign-out.govuk-link")
        expect(response.body).to have_link("Sign out", href: "/sign-out")
      end
    end

    context "when a user is not signed in" do
      before do
        allow(Helper::Session).to receive(:is_logged_in?).and_return(false)
      end

      it "displays the sign out button" do
        expect(response.body).not_to have_css("#sign-out.govuk-link")
      end
    end
  end
end
