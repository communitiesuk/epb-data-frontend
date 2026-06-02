require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::LinkingCertificatesToRecommendations", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/linking-certificates-to-recommendations" do
    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/linking-certificates-to-recommendations", title: "Linking certificates to recommendations"
  end
end
