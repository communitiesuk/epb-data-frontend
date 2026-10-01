describe "Acceptance::DeleteAccount", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data"
  end

  let(:delete_user_use_case) { instance_double(UseCase::DeleteUser) }

  let(:app) do
    fake_container = instance_double(Container)
    allow(fake_container).to receive(:get_object).with(:delete_user_use_case).and_return(delete_user_use_case)

    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "test" * 16
      run Controller::ApiController.new(container: fake_container)
    end
  end

  describe "get /api/my-account/delete-account" do
    context "when the user is authenticated" do
      before do
        get "/api/my-account/delete-account", {}, {
          "rack.session" => {
            id_token: "test-user-id",
            email_address: "test@example.com",
          },
        }
      end

      it "returns status 200" do
        expect(last_response.status).to eq(200)
      end

      it "has cache-control no-store" do
        expect(last_response.headers["cache-control"]).to eq "no-store"
      end

      it "has the correct header" do
        expect(last_response.body).to have_css("h1.govuk-heading-xl", text: "Delete your account")
      end

      it "shows explanatory text and OneLogin link" do
        expect(last_response.body).to include("This will not delete your GOV.UK One Login account. To delete your One Login account, ")
        expect(last_response.body).to have_link("follow the GOV.UK One Login guidance", href: "https://www.gov.uk/guidance/deleting-your-govuk-one-login")
      end

      it "shows a form that posts to /api/delete-account and a warning button" do
        expect(last_response.body).to include('form action="/api/my-account/delete-account" method="post"')
        expect(last_response.body).to have_css("input[name='authenticity_token']", visible: :hidden)
        expect(last_response.body).to have_button("Delete account", id: "confirm-delete-account", class: "govuk-button--warning")
      end

      it "has a back link to the account page" do
        expect(last_response.body).to have_css("a.govuk-back-link[href='/api/my-account']")
      end
    end

    context "when user is not authenticated" do
      before do
        get "#{local_host}/api/my-account/delete-account"
      end

      it "redirects to the login page with the right referer" do
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/login/authorize?referer=api%2Fmy-account%2Fdelete-account")
      end
    end
  end

  describe "post /api/my-account/delete-account" do
    context "when the user is authenticated" do
      before do
        allow(delete_user_use_case).to receive(:execute)

        post "/api/my-account/delete-account", {}, {
          "rack.session" => {
            id_token: "test-user-id",
            email_address: "test@example.com",
          },
        }
      end

      it "redirects to gov.uk one login sign-out" do
        expect(last_response.status).to eq(302)
        delete_state = last_request.env["rack.session"]["delete_state"]
        expect(delete_state).not_to be_nil
        expect(last_response.headers["Location"]).to match "https://oidc.integration.account.gov.uk/logout?id_token_hint=test-user-id&post_logout_redirect_uri=http%3A%2F%2Fexample.org%2Faccount-deleted&state=#{delete_state}"
      end

      it "calls the delete use case" do
        expect(delete_user_use_case).to have_received(:execute).with("test-user-id")
      end

      it "replaces the state" do
        expect(last_request.env["rack.session"].keys).to eq %w[delete_state]
      end
    end

    context "when the user is not authenticated" do
      before do
        post "#{local_host}/api/my-account/delete-account"
      end

      it "redirects to the login page with the right referer" do
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/login/authorize?referer=api%2Fmy-account%2Fdelete-account")
      end
    end
  end
end
