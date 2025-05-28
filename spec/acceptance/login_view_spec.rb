describe "Acceptance::Login", type: :feature do
  include RSpecFrontendServiceMixin
  let(:login_url) do
    "http://get-energy-performance-data/login"
  end

  let(:auth_url) do
    "http://get-energy-performance-data/login/callback"
  end

  let(:response) { get login_url }

  let(:onelogin_gateway) do
    instance_double(Gateway::OneloginTokenGateway)
  end

  let(:sign_onelogin_request_test_use_case) do
    instance_double(UseCase::SignOneloginRequest)
  end

  let(:request_onelogin_token_use_case) do
    instance_double(UseCase::RequestOneloginToken)
  end

  let(:token_response) do
    {
      "access_token": "SlAV32hkKG",
      "token_type": "Bearer",
      "expires_in": 180,
      "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg",
    }
  end

  let(:app) do
    fake_container = instance_double(Container)
    allow(fake_container).to receive(:get_object).with(:sign_onelogin_request_use_case).and_return(sign_onelogin_request_test_use_case)
    allow(fake_container).to receive(:get_object).with(:request_onelogin_token_use_case).and_return(request_onelogin_token_use_case)

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
      allow(sign_onelogin_request_test_use_case).to receive(:execute).and_return("test_signed_request")
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
        expect(sign_onelogin_request_test_use_case).to have_received(:execute).with(
          aud: "#{ENV['ONELOGIN_HOST_URL']}/authorize",
          client_id: ENV["ONELOGIN_CLIENT_ID"],
          redirect_uri: "#{last_request.scheme}://#{last_request.host_with_port}/login/callback",
          state: last_response.cookies["state"].first,
          nonce: last_response.cookies["nonce"].first,
        )
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/login/callback" do
    before do
      allow(request_onelogin_token_use_case).to receive(:execute).and_return(token_response)
      allow(Helper::Onelogin).to receive(:check_one_login_errors).and_return(true)
    end

    context "when the request is received" do
      before do
        get auth_url, { code: "test_code", state: "test_state" }, { "HTTP_COOKIE" => "nonce=test_nonce; state=test_state" }
      end

      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "calls the check_one_login_errors method" do
        expect(Helper::Onelogin).to have_received(:check_one_login_errors).with({ code: "test_code", state: "test_state" })
      end

      it "redirects to the type of properties page" do
        expect(last_response).to redirect_to("/type-of-properties")
      end
    end

    context "when request raises StateMismatch error" do
      before do
        get auth_url, { code: "test_code", state: "test_state" }, { "HTTP_COOKIE" => "nonce=test_nonce; state=different_test_state" }
      end

      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(last_response.headers["Location"]).to eq("http://get-energy-performance-data/login")
      end
    end
  end
end
