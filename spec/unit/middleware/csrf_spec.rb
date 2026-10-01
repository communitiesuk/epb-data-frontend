require "rack/protection"

describe "AuthenticationToken", type: :feature do
  include RSpecFrontendServiceMixin

  context "when the CSRF in enabled" do
    let(:app) do
      Rack::Builder.new do
        use Rack::Protection::AuthenticityToken
        use Rack::Protection::RemoteReferrer
        run Controller::OptOutController.new
      end
    end
    let(:base_url) { "http://get-energy-performance-data" }

    %w[opt-out/owner cookies filter-properties type-of-properties].each do |path|
      it "a post to the #{path} endpoint return a forbidden status code" do
        response =  post "#{base_url}/#{path}", { data: "yes" }
        expect(response.status).to eq(403)
      end
    end
  end
end
