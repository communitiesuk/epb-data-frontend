require_relative "../../shared_examples/shared_guidance_page"

describe "Acceptance::DataDictionary", type: :feature do
  include RSpecFrontendServiceMixin

  describe "get .get-energy-certificate-data.epb-frontend/guidance/data-dictionary" do
    it_behaves_like "when checking the rendering of data passed to a guidance page", path: "/guidance/data-dictionary", title: "Data dictionary"
  end
end
