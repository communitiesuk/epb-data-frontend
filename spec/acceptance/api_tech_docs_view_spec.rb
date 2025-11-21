require_relative "../shared_context/shared_api_tech_docs"

describe "Acceptance::ApiTechnicalDocumentation", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/api-technical-documentation" do
    include_context "when viewing api tech docs"

    let(:path) { "/api-technical-documentation" }

    context "when the start page is rendered" do
      let(:response) { get "#{base_url}#{path}" }

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Energy certificate data API documentation")
      end

      it "has the navigation component" do
        expect(response.body).to have_css("nav.app-subnav")
      end

      it "the navigation has a link to each page" do
        expect(response.body).to have_css("ul.app-subnav__section li", count: 16)
      end

      it "the navigation has a 2 sections" do
        expect(response.body).to have_css("nav h3", text: "General documentation")
        expect(response.body).to have_css("nav h3", text: "API specifications")
      end

      it "has the expected navigation links" do
        page_urls.each do |link|
          url = "#{path}/#{link}"
          expect(response.body).to have_css("ul.app-subnav__section li a[href='#{url}']")
        end
      end
    end

    context "when requesting each api document" do
      it "returns status 200 for each page" do
        page_urls.each do |link|
          response = get "#{base_url}#{path}/#{link}"
          expect(response.status).to eq(200)
        end
      end

      it "each page has the correct sections" do
        page_urls.each do |link|
          response = get "#{base_url}#{path}/#{link}"
          expect(response.body).to have_css("ul.app-subnav__section")
          expect(response.body).to have_css("h1")
          expect(response.body).to have_css("h2")
        end
      end

      context "when calling the pages that document endpoints" do
        it "each page has the expected sections" do
          end_points.each do |link|
            response = get "#{base_url}#{path}/#{link}"
            expect(response.body).to have_css("h2", text: "Method")
            expect(response.body).to have_css("h2", text: "Response")
            expect(response.body).to have_css("h2", text: "Example")
          end
        end

        context "when calling the end point documents that have params" do
          it "each page has the expected sections" do
            end_points_params.each do |link|
              response = get "#{base_url}#{path}/#{link}"
              expect(response.body).to have_css("h2", text: "Parameters")
            end
          end
        end
      end
    end
  end
end
