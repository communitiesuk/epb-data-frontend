require_relative "../../shared_examples/shared_guidance_page"
describe "Acceptance::ChangesToTheMethodAndMethodology", type: :feature do
  include RSpecFrontendServiceMixin

  describe "get .get-energy-certificate-data.epb-frontend/guidance/changes-to-the-format-and-methodology" do
    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/changes-to-the-format-and-methodology", title: "Changes to the format and methodology"
  end
end
