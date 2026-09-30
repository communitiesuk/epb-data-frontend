require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::EnergyCertificateDataApis", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/energy-certificate-data-apis" do
    let(:response) { get "#{base_url}/guidance/energy-certificate-data-apis" }

    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/energy-certificate-data-apis", title: "Energy certificate data APIs", dont_render_guidance: false

    context "when user is authenticated" do
      before do
        allow(Helper::Session).to receive_messages(
          get_session_value: "user_id",
        )

        allow(ViewModels::MyAccount).to receive_messages(
          get_bearer_token: "kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r",
          unsubscribed?: false,
        )
      end

      after do
        allow(Helper::Session).to receive_messages(is_logged_in?: false)
      end

      it "shows the bearer token" do
        expect(response.body).to have_css("#bearer-token-value", text: "kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r")
      end
    end
  end
end
