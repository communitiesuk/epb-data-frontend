describe "Acceptance::OptOutOwner", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/name" do
    let(:response) { get "#{base_url}/opt-out/name" }

    context "when the user is authenticated" do
      before do
        allow(Helper::Session).to receive_messages(
          is_user_authenticated?: true,
          get_email_from_session: "test@email.com",
        )
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "contains the correct h1 header" do
        expect(response.body).to have_selector("h1", text: "What is your full name?")
      end

      it "has the label and input for the name" do
        expect(response.body).to have_css("label#label_name", text: "First and last name")
        expect(response.body).to have_css("input#name[type='text']", count: 1)
      end

      it "has the correct Continue button" do
        expect(response.body).to have_css("button[type='submit']", text: "Continue")
      end
    end

    context "when the user is not authenticated" do
      before do
        allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "User is not authenticated")
      end

      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(response.location).to include("/login?referer=opt-out")
      end
    end
  end
end
