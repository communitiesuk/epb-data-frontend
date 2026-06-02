require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::DataProtectionRequirements", type: :feature do
  include RSpecFrontendServiceMixin

  describe "get .get-energy-certificate-data.epb-frontend/guidance/data-protection-requirements" do
    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/data-protection-requirements", title: "Data protection requirements"
  end
end
