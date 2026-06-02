require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::LicensingRestrictions", type: :feature do
  include RSpecFrontendServiceMixin

  describe "get .get-energy-certificate-data.epb-frontend/guidance/licensing-restrictions" do
    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/licensing-restrictions", title: "Licensing restrictions"
  end
end
