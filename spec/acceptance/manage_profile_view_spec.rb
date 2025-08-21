describe "Acceptance::ManageProfile", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/manage-profile"
  end

  let(:response) { get local_host }

  describe "get .get-energy-certificate-data.epb-frontend/manage-profile" do
    context "when the manage profile page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "has the correct page title" do
        expect(response.body).to have_css("h1", text: "Manage profile")
      end

      it "shows the client credentials toggle section" do
        expect(response.body).to have_css("#client-credentials-section.govuk-accordion__section")
      end

      it "shows the bearer token toggle section" do
        expect(response.body).to have_css("#bearer-token-section.govuk-accordion__section")
      end
    end

    context "when a user is signed in" do
      before do
        allow(Helper::Session).to receive(:is_logged_in?).and_return(true)
      end

      it "displays the sign out button" do
        expect(response.body).to have_link("Sign out", href: "/sign-out")
      end
    end

    context "when a user is not signed in" do
      before do
        allow(Helper::Session).to receive(:is_logged_in?).and_return(false)
      end

      it "displays the sign out button" do
        expect(response.body).not_to have_link("Sign out", href: "/sign-out")
      end
    end
  end
end
