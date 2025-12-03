describe "Acceptance::Login", type: :feature do
  include RSpecFrontendServiceMixin
  let(:login_url) do
    "http://get-energy-performance-data/login"
  end

  let(:callback_url) do
    "http://get-energy-performance-data/login/callback"
  end

  let(:callback_admin_url) do
    "#{callback_url}/admin"
  end

  let(:response) { get login_url }

  let(:onelogin_gateway) do
    instance_double(Gateway::OneloginGateway)
  end

  let(:sign_onelogin_request_test_use_case) do
    instance_double(UseCase::SignOneloginRequest)
  end

  let(:request_onelogin_token_use_case) do
    instance_double(UseCase::RequestOneloginToken)
  end

  let(:get_onelogin_user_info_use_case) do
    instance_double(UseCase::GetOneloginUserInfo)
  end

  let(:get_user_id_use_case) do
    instance_double(UseCase::GetUserId)
  end

  let(:get_user_creds_gateway) do
    instance_double(Gateway::UserCredentialsGateway)
  end

  let(:token_response) do
    {
      "access_token": "SlAV32hkKG",
      "token_type": "Bearer",
      "expires_in": 180,
      "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg",
    }
  end

  let(:user_info_response) do
    {
      email: "test@email.com",
      email_verified: true,
      sub: "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw=",
    }
  end

  let(:app) do
    fake_container = instance_double(Container)
    allow(fake_container).to receive(:get_object).with(:sign_onelogin_request_use_case).and_return(sign_onelogin_request_test_use_case)
    allow(fake_container).to receive(:get_object).with(:request_onelogin_token_use_case).and_return(request_onelogin_token_use_case)
    allow(fake_container).to receive(:get_object).with(:get_onelogin_user_info_use_case).and_return(get_onelogin_user_info_use_case)
    allow(fake_container).to receive(:get_object).with(:get_user_id_use_case).and_return(get_user_id_use_case)

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
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "shows the correct title and body text" do
        expect(response.body).to have_selector("h1", text: "Get energy performance of buildings data")
        expect(response.body).to have_selector("p.govuk-body", text: "If you’ve used other government services for example, to file a Self Assessment tax return or apply for or renew a passport, you can use the same login details here.")
        expect(response.body).to have_selector("strong", text: "Self Assessment tax return")
        expect(response.body).to have_selector("strong", text: "apply for or renew a passport")
        expect(response.body).to have_selector("p.govuk-body", text: "If you don’t have a One Login, you can create one when you start.")
      end

      it "has the correct Start now button" do
        expect(response.body).to have_link("Start now", href: "/login/authorize")
      end
    end

    context "when the request received includes a referer" do
      context "when referer is 'api/my-account'" do
        before do
          get "#{login_url}?referer=api/my-account"
        end

        it "has the correct referer for Start now button (authorize_url)" do
          expect(last_response.body).to have_link("Start now", href: "/login/authorize?referer=api/my-account")
        end
      end

      context "when referer is '/opt-out'" do
        before do
          allow(Helper::Session).to receive(:get_session_value).and_return({ owner: "yes" })
          get "#{login_url}?referer=/opt-out"
        end

        it "returns status 200" do
          expect(response.status).to eq(200)
        end

        it "has the correct referer for Start now button (authorize_url)" do
          expect(last_response.body).to have_link("Start now", href: "/login/authorize?referer=/opt-out")
        end

        it "has the correct title" do
          expect(last_response.body).to have_css("h1", text: "Create your GOV.UK One Login or sign in")
        end

        it "has the correct text" do
          expect(last_response.body).to have_css("p", text: "You need to log in or sign up to make an opt out request.")
        end

        it "there is no back button" do
          expect(last_response.body).not_to have_link("Back", href: "/previous_page")
        end

        context "when the owner is not confirmed in the session data" do
          before do
            allow(Helper::Session).to receive(:get_session_value).and_return({ owner: "no" })
            get "#{login_url}?referer=/opt-out"
          end

          it "sends them to the ineligible page" do
            expect(last_response.headers["location"]).to include("/opt-out/ineligible")
          end
        end

        context "when the occupier is not confirmed in the session data" do
          before do
            allow(Helper::Session).to receive(:get_session_value).and_return({ occupier: "no" })
            get "#{login_url}?referer=/opt-out"
          end

          it "sends them to the ineligible page" do
            expect(last_response.headers["location"]).to include("/opt-out/ineligible")
          end
        end
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/login/authorize" do
    context "when the request is received" do
      before do
        allow(sign_onelogin_request_test_use_case).to receive(:execute).and_return("test_signed_request")
        get "#{login_url}/authorize"
      end

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

    context "when the request is received with api/my-account referer parameter" do
      before do
        allow(sign_onelogin_request_test_use_case).to receive(:execute).and_return("test_signed_request")
        get "#{login_url}/authorize?referer=api/my-account"
      end

      it "calls the use case with the correct arguments" do
        expect(sign_onelogin_request_test_use_case).to have_received(:execute).with(
          aud: "#{ENV['ONELOGIN_HOST_URL']}/authorize",
          client_id: ENV["ONELOGIN_CLIENT_ID"],
          redirect_uri: "#{last_request.scheme}://#{last_request.host_with_port}/login/callback/admin",
          state: last_response.cookies["state"].first,
          nonce: last_response.cookies["nonce"].first,
        )
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/login/callback" do
    before do
      allow(request_onelogin_token_use_case).to receive(:execute).and_return(token_response)
      allow(get_onelogin_user_info_use_case).to receive(:execute).and_return(user_info_response)
      allow(Helper::Onelogin).to receive(:check_one_login_errors).and_return(true)
      allow(Helper::Session).to receive(:set_session_value)
      allow(get_user_id_use_case).to receive(:execute).and_return("e40c46c3-4636-4a8a-abd7-be72e1a525f6")
    end

    context "when the request is received" do
      before do
        Timecop.freeze(Time.utc(2025, 6, 25, 12, 0, 0))
        get callback_url, { code: "test_code", state: "test_state" }, { "HTTP_COOKIE" => "nonce=test_nonce; state=test_state" }
      end

      after do
        Timecop.return
      end

      it "calls the request_onelogin_token_use_case with the right arguments" do
        expect(request_onelogin_token_use_case).to have_received(:execute).with({ code: "test_code", redirect_uri: "http://get-energy-performance-data/login/callback" })
      end

      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "calls the check_one_login_errors method" do
        expect(Helper::Onelogin).to have_received(:check_one_login_errors).with({ code: "test_code", state: "test_state" })
      end

      it "calls set_session_value for the email address" do
        expect(Helper::Session).to have_received(:set_session_value).with(anything, :email_address, "test@email.com")
      end

      it "calls the get user id use case" do
        expect(get_user_id_use_case).to have_received(:execute).with("urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw=")
      end

      it "sets the user id into the session" do
        expect(Helper::Session).to have_received(:set_session_value).with(anything, :user_id, "e40c46c3-4636-4a8a-abd7-be72e1a525f6")
      end

      it "redirects to the type of properties page" do
        redirect_uri = URI(last_response.location)
        expect(redirect_uri.path).to eq("/type-of-properties")
        expect(redirect_uri.query).to eq("nocache=1750852800")
      end
    end

    context "when request raises StateMismatch error" do
      before do
        get callback_url, { code: "test_code", state: "test_state" }, { "HTTP_COOKIE" => "nonce=test_nonce; state=different_test_state" }
      end

      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(last_response.headers["Location"]).to eq("http://get-energy-performance-data/login")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/login/callback/admin" do
    before do
      allow(request_onelogin_token_use_case).to receive(:execute).and_return(token_response)
      allow(get_onelogin_user_info_use_case).to receive(:execute).and_return(user_info_response)
      allow(Helper::Onelogin).to receive(:check_one_login_errors).and_return(true)
      allow(Helper::Session).to receive(:set_session_value)
      allow(get_user_id_use_case).to receive(:execute).and_return("e40c46c3-4636-4a8a-abd7-be72e1a525f6")
    end

    context "when the request is received" do
      before do
        Timecop.freeze(Time.utc(2025, 6, 25, 12, 0, 0))
        get callback_admin_url, { code: "test_code", state: "test_state" }, { "HTTP_COOKIE" => "nonce=test_nonce; state=test_state" }
      end

      after do
        Timecop.return
      end

      it "calls the request_onelogin_token_use_case with the right arguments" do
        expect(request_onelogin_token_use_case).to have_received(:execute).with({ code: "test_code", redirect_uri: "http://get-energy-performance-data/login/callback/admin" })
      end

      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "redirects to the my-account page" do
        redirect_uri = URI(last_response.location)
        expect(redirect_uri.path).to eq("/api/my-account")
        expect(redirect_uri.query).to eq("nocache=1750852800")
      end
    end

    context "when request raises StateMismatch error" do
      before do
        get callback_admin_url, { code: "test_code", state: "test_state" }, { "HTTP_COOKIE" => "nonce=test_nonce; state=different_test_state" }
      end

      it "returns status 302" do
        expect(last_response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(last_response.headers["Location"]).to eq("http://get-energy-performance-data/login?referer=api/my-account")
      end
    end
  end
end
