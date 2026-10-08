require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::EnergyCertificateDataApis", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  let(:get_user_info_use_case) do
    instance_double(UseCase::GetUserInfo)
  end

  let(:app) do
    fake_container = instance_double(Container)
    allow(fake_container).to receive(:get_object).with(:get_user_info_use_case).and_return(get_user_info_use_case)

    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "test" * 16
      run Controller::GuidanceController.new(container: fake_container)
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/guidance/energy-certificate-data-apis" do
    let(:response) { get "#{base_url}/guidance/energy-certificate-data-apis" }

    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/energy-certificate-data-apis", title: "Energy certificate data APIs", dont_render_guidance: false

    context "when user is authenticated" do
      before do
        allow(get_user_info_use_case).to receive(:execute).and_return({ bearer_token: "mock_value", opt_out: false })
        allow(Helper::Session).to receive_messages(
          get_session_value: "user_id",
        )

        allow(ViewModels::MyAccount).to receive_messages(
          get_bearer_token: "kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r",
          unsubscribed?: false,
        )
      end

      it "shows the bearer token" do
        expect(response.body).to have_css("#bearer-token-value", text: "kfhbks750D0RnC2oKGsoM936wKmtd4ZcoSw489rPo4FDqQ2SYQVtVnQ4PhZ33b46YZPNZXo6r")
      end
    end
  end
end
