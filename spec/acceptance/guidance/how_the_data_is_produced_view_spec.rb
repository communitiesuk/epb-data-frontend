require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::HowTheDataIsProduced", type: :feature do
  include RSpecFrontendServiceMixin

  describe "get .get-energy-certificate-data.epb-frontend/guidance/how-the-data-is-produced" do
    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/how-the-data-is-produced", title: "How the data is produced"
  end
end
