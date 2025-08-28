describe "Acceptance::MyAccount", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data/api/my-account"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/api/my-account" do
    before do
      Helper::Toggles.set_feature("epb-frontend-data-restrict-user-access", true)
      allow(Helper::Session).to receive_messages(is_user_authenticated?: true, get_email_from_session: "test@email.com")
      allow(ViewModels::MyAccount).to receive(:get_bearer_token).and_return("kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r")
    end

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

      it "shows the email address" do
        expect(response.body).to have_css("#email-address-value", text: "test@email.com")
      end

      it "shows the bearer token" do
        expect(response.body).to have_css("#bearer-token-value", text: "kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r")
      end
    end
  end
end
