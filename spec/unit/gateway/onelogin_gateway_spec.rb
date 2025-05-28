describe Gateway::OneloginGateway do
  include RSpecUnitMixin
  subject(:gateway) { described_class.new }

  describe "#exchange_code_for_token" do
    let(:url) { "https://oidc.integration.account.gov.uk/token" }
    let(:args) do
      {
        code: "test_code",
        redirect_uri: "https://example.com/callback",
        jwt_assertion: "test_jwt_assertion",
      }
    end

    let(:response) { gateway.exchange_code_for_token(**args) }

    context "when the response is successful" do
      before do
        stub_request(:post, url)
          .with(
            body: {
              "client_assertion" => "test_jwt_assertion",
              "client_assertion_type" => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
              "code" => "test_code",
              "grant_type" => "authorization_code",
              "redirect_uri" => "https://example.com/callback",
            },
          )
          .to_return(
            body: '{
            "access_token": "test_access_token",
            "token_type": "Bearer",
            "expires_in": 3600,
            "id_token": "test_id_token"
          }',
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "return a token hash" do
        expect(response).to be_a(Hash)
        expect(response).to eq({ "access_token" => "test_access_token", "expires_in" => 3600, "id_token" => "test_id_token", "token_type" => "Bearer" })
      end
    end

    context "when the response is not a valid json" do
      before do
        stub_request(:post, url)
          .to_return(
            body: "not a valid json",
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "raises a NetworkError" do
        expect {
          gateway.exchange_code_for_token(**args)
        }.to raise_error(Errors::NetworkError, /Network error during token exchange/)
      end
    end

    context "when the response is not 2xx" do
      it "raises a InvalidGrantError if invalid_grant error is returned" do
        stub_request(:post, url)
          .to_return(
            status: 400,
            body: '{"error": "invalid_grant", "error_description": "Invalid authorization code"}',
            headers: { "Content-Type" => "application/json" },
          )

        expect {
          gateway.exchange_code_for_token(**args)
        }.to raise_error(Errors::InvalidGrantError, /Invalid grant: Invalid authorization code/)
      end

      it "raises a TokenExchangeError for other errors" do
        stub_request(:post, url)
          .to_return(
            status: 400,
            body: '{"error": "some_error", "error_description": "An error occurred"}',
            headers: { "Content-Type" => "application/json" },
          )

        expect {
          gateway.exchange_code_for_token(**args)
        }.to raise_error(Errors::TokenExchangeError, /OneLogin token exchange failed: some_error - An error occurred/)
      end
    end
  end

  describe "#get_user_email" do
    let(:url) { "https://oidc.integration.account.gov.uk/userinfo" }

    let(:access_token) { "test_access_token" }

    let(:response) { gateway.get_user_email(access_token:) }

    context "when the response is successful" do
      before do
        stub_request(:get, url)
          .with(
            headers: {
              "Authorization" => "Bearer #{access_token}",
            },
          )
          .to_return(
            body: '{
              "sub": "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw=",
              "email": "test@example.com",
              "email_verified": true,
              "phone_number": "+441406946277",
              "phone_number_verified": true
            }',
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "returns the user email and email_verified values" do
        expected_user_hash = { email: "test@example.com", email_verified: true }
        expect(response).to eq(expected_user_hash)
      end
    end

    context "when the response is not 2xx" do
      it "raises a AuthenticationError if invalid_token error is returned" do
        stub_request(:get, url)
          .to_return(
            status: 401,
            body: '{"error": "invalid_token", "error_description": "The Access Token expired"}',
            headers: { "Content-Type" => "application/json" },
          )

        expect {
          gateway.get_user_email(access_token:)
        }.to raise_error(Errors::AuthenticationError, /Failed to fetch user email: invalid_token. The Access Token expired/)
      end

      it "raises a NetworkError if timeout happens" do
        stub_request(:get, url)
          .to_timeout

        expect {
          gateway.get_user_email(access_token:)
        }.to raise_error(Errors::NetworkError, /Network error during user email fetch: execution expired/)
      end
    end

    context "when the email is not verified" do
      before do
        stub_request(:get, url)
          .with(
            headers: {
              "Authorization" => "Bearer #{access_token}",
            },
          )
          .to_return(
            body: '{
              "sub": "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw=",
              "email": "test@example.com",
              "email_verified": false,
              "phone_number": "+441406946277",
              "phone_number_verified": true
            }',
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "raises a UserEmailNotVerified error" do
        expect {
          gateway.get_user_email(access_token:)
        }.to raise_error(Errors::UserEmailNotVerified, /Email not verified for user: test@example.com/)
      end
    end
  end
end
