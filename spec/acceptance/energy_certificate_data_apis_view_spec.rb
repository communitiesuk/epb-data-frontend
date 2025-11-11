describe "Acceptance::EnergyCertificateDataApis", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/api/energy-certificate-data-apis" do
    let(:response) { get "#{base_url}/api/energy-certificate-data-apis" }

    context "when the start page is rendered" do
      before do
        allow(Helper::Session).to receive_messages(is_user_authenticated?: false)
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Energy certificate data APIs")
      end

      it "has the correct content under the title" do
        expect(response.body).to have_css("p", text: "Learn about the APIs we offer for software developers and how you can connect to them.")
      end

      it "has the correct content for data available section" do
        expect(response.body).to have_css("h2", text: "Data available")
        expect(response.body).to have_css("p", text: "Use the API to get data on:")
      end

      it "has the correct content for authentication section" do
        expect(response.body).to have_css("h2", text: "Authentication")
        expect(response.body).to have_link("sign in", href: "/login?referer=api/energy-certificate-data-apis")
        expect(response.body).to have_link("create an account", href: "/login?referer=api/energy-certificate-data-apis")
        expect(response.body).to have_link("My account", href: "/api/my-account")
      end

      it "has the correct content for Open API specification section" do
        expect(response.body).to have_css("h2", text: "Open API specification")
        expect(response.body).to have_link("OpenAPI Specification", href: "https://swagger.io/specification/")
        expect(response.body).to have_link("Swagger Codegen", href: "https://swagger.io/tools/swagger-codegen/")
      end

      it "has the correct content for conditions of use section" do
        expect(response.body).to have_css("h2", text: "Conditions of use")
        expect(response.body).to have_link("Licensing restrictions", href: "/licensing-restrictions")
        expect(response.body).to have_link("Data protection requirements", href: "/data-protection-requirements")
      end

      it "has the correct content for rate limiting section" do
        expect(response.body).to have_css("h2", text: "Rate limiting")
        expect(response.body).to have_css("p", text: "If you continually hit this rate limit, contact us to discuss your application design and whether it’s appropriate to raise your rate limit.")
      end

      it "has the correct content for technical documentation section" do
        expect(response.body).to have_css("h2", text: "Technical documentation")
        expect(response.body).to have_link(href: "#")
        expect(response.body).to have_link(href: "#")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
        expect(response.body).to have_content("Visit the guidance page for information on:")
      end

      it "has the correct MHCLG contact email" do
        expect(response.body).to have_content("mhclg.digital-services@communities.gov.uk")
      end
    end

    context "when user is authenticated" do
      before do
        allow(Helper::Session).to receive_messages(is_user_authenticated?: true)
        allow(ViewModels::MyAccount).to receive(:get_bearer_token).and_return("kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r")
      end

      after do
        allow(Helper::Session).to receive_messages(is_user_authenticated?: false)
      end

      it "shows the bearer token" do
        expect(response.body).to have_css("#bearer-token-value", text: "kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r")
      end
    end
  end
end
