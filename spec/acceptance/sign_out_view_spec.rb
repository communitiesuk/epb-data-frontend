describe "Acceptance::SignOut", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data"
  end

  let(:response) { get "#{local_host}/signed-out" }

  it "returns status 200" do
    expect(response.status).to eq(200)
  end

  it "has correct header" do
    expect(response.body).to have_selector("h1", text: "You have been signed out")
  end

  it "displays the title the same as the main header value" do
    expect(response.body).to have_title "You have been signed out – GOV.UK"
  end

  it "the one login link is included" do
    expect(response.body).to have_link("GOV.UK One Login", href: "/login/authorize?referer=api/my-account")
  end

  it "includes the link text" do
    expect(response.body).to have_selector("p", text: "To go back, sign in to our service using")
  end

  it "the page does not include the sign out link" do
    expect(response.body).not_to have_selector("button", text: "Sign out")
  end

  describe "get .get-energy-certificate-data.epb-frontend/sign-out" do
    let(:id_token) do
      "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg"
    end

    context "with a session" do
      before do
        get "#{local_host}/sign-out", {}, {
          "rack.session" => {
            id_token:,
            email_address: "test@example.com",
          },
        }
      end

      it "redirects to the OneLogin authorization URL with the correct host and path" do
        expect(last_response.status).to eq(302)
        uri = URI(last_response.headers["Location"])
        expect(uri.host).to eq(ENV["ONELOGIN_HOST_URL"].gsub("https://", ""))
        expect(uri.path).to eq("/logout")
      end

      it "redirects to the OneLogin authorization URL with the correct query parameters" do
        uri = URI(last_response.headers["Location"])
        query_params = Rack::Utils.parse_query(uri.query)
        expect(query_params["post_logout_redirect_uri"]).to eq("#{local_host}/signed-out")
        expect(query_params["id_token_hint"]).to eq(id_token)
      end

      it "clear the session" do
        expect(last_request.env["rack.session"]).not_to include "id_token"
      end
    end

    context "without a session" do
      before do
        get "#{local_host}/sign-out"
      end

      it "redirects to the signed out page" do
        expect(last_response.status).to eq(302)
        expect(last_response.headers["Location"]).to eq "http://get-energy-performance-data/signed-out"
      end
    end
  end
end
