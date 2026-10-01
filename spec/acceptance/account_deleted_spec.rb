describe "Acceptance::AccountDeleted", type: :feature do
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

  describe "get /account-deleted" do
    context "when accessed with a matching state" do
      before do
        get "#{local_host}/account-deleted", { state: "123" }, { "rack.session" => { delete_state: "123" } }
      end

      it "returns status 200" do
        expect(last_response.status).to eq(200)
      end

      it "has the correct header" do
        expect(last_response.body).to have_css("h1.govuk-heading-xl", text: "Delete your account")
      end

      it "shows the confirmation message" do
        expect(last_response.body).to include("Your account has been deleted")
      end

      it "does not have a back link to the account page" do
        expect(last_response.body).not_to have_css("a.govuk-back-link")
      end

      it "clears the session" do
        expect(last_request.env["rack.session"]).to be_empty
      end
    end

    context "when accessed with non-matching state" do
      before do
        get "#{local_host}/account-deleted", { state: "123" }, { "rack.session" => { delete_state: "xxx" } }
      end

      it "returns a redirect to home" do
        expect(last_response.status).to eq 302
        expect(last_response.headers["Location"]).to eq "http://get-energy-performance-data/"
      end
    end

    context "when accessed with no state" do
      before do
        get "#{local_host}/account-deleted", { state: "123" }
      end

      it "returns a redirect to home" do
        expect(last_response.status).to eq 302
        expect(last_response.headers["Location"]).to eq "http://get-energy-performance-data/"
      end
    end
  end
end
