describe "Acceptance::Login", type: :feature do
  include RSpecFrontendServiceMixin
  let(:login_url) do
    "http://get-energy-performance-data/login"
  end

  let(:response) { get login_url }

  let(:use_case) do
    instance_double(UseCase::SignOneloginRequest)
  end

  let(:app) do
    fake_container = instance_double(Container)
    allow(fake_container).to receive(:get_object).with(:sign_onelogin_request_use_case).and_return(use_case)

    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "test" * 16
      run Controller::UserController.new(container: fake_container)
    end
  end

  around do |example|
    original_stage = ENV["STAGE"]
    ENV["STAGE"] = "mock"
    example.run
    ENV["STAGE"] = original_stage
  end

  describe "get .get-energy-certificate-data.epb-frontend/login" do
    context "when the request received login page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/data-access-options"
      end

      it "shows the correct title and body text" do
        expect(response.body).to have_selector("h1", text: "Get energy certificate data")
        expect(response.body).to have_selector("p.govuk-body", text: "You'll need a GOV.UK One Login to use this service. If you do not have a GOV.UK One Login, you can create one.")
      end

      it "has the correct Start now button" do
        expect(response.body).to have_link("Start now", href: "/login/authorize")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/login/authorize" do
    before do
      allow(use_case).to receive(:execute).and_return("test_signed_request")
      get "#{login_url}/authorize"
    end

    context "when the request is received" do
      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "redirects to the OneLogin authorization URL with the correct host and path" do
        uri = URI(last_response.headers["Location"])
        expect(uri.host).to eq(ENV["ONELOGIN_HOST_URL"].gsub("https://", ""))
        expect(uri.path).to eq("/authorize")
      end

      it "redirects to the OneLogin authorization URL with the correct query parameters" do
        uri = URI(last_response.headers["Location"])
        query_params = Rack::Utils.parse_query(uri.query)
        expect(query_params["response_type"]).to eq("code")
        expect(query_params["scope"]).to eq("openid email")
        expect(query_params["client_id"]).to eq(ENV["ONELOGIN_CLIENT_ID"])
        expect(query_params["request"]).to eq("test_signed_request")
      end

      it "does not return nil for nonce and state cookies" do
        expect(last_response.cookies["nonce"].first).not_to be_nil
        expect(last_response.cookies["state"].first).not_to be_nil
      end

      it "calls the use case with the correct arguments" do
        expect(use_case).to have_received(:execute).with(
          aud: "#{ENV['ONELOGIN_HOST_URL']}/authorize",
          client_id: ENV["ONELOGIN_CLIENT_ID"],
          redirect_uri: "#{last_request.scheme}://#{last_request.host_with_port}/type-of-properties",
          state: last_response.cookies["state"].first,
          nonce: last_response.cookies["nonce"].first,
        )
      end
    end
  end
end
