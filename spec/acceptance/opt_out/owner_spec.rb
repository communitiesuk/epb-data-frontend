describe "Acceptance::OptOutOwner", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/owner" do
    let(:response) { get "#{base_url}/opt-out/owner" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "contains the correct h1 header" do
      expect(response.body).to have_selector("h1", text: "Are you the legal owner of the property that you want to opt out?")
    end

    it "has the Yes radio button" do
      expect(response.body).to have_css("label#label-yes", text: "Yes")
      expect(response.body).to have_css("input#owner_yes[type='radio']", count: 1)
    end

    it "has the No radio button" do
      expect(response.body).to have_css("label#label-no", text: "No")
      expect(response.body).to have_css("input#owner_no[type='radio']", count: 1)
    end

    it "has the correct Continue button" do
      expect(response.body).to have_css("button[type='submit']", text: "Continue")
    end

    it "shows a back link and redirects to previous page" do
      expect(response.body).to have_link("Back", href: "/opt-out/reason")
    end
  end

  describe "post .get-energy-certificate-data.epb-frontend/opt-out/owner" do
    context "when yes radio button is selected" do
      let(:response) { post "#{base_url}/opt-out/owner", { owner: "yes" } }

      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(response.location).to include("/login?referer=/opt-out")
      end
    end

    context "when no radio button is selected" do
      let(:response) { post "#{base_url}/opt-out/owner", { owner: "no" } }

      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(response.location).to include("/opt-out/occupant")
      end
    end
  end
end
