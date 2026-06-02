shared_examples "when checking the rendering of data passed to a guidance page" do |path:, title:, dont_render_guidance: true|
  context "when rendering #{path}" do
    let(:base_url) { "http://get-energy-performance-data" }
    let(:response) { get "#{base_url}#{path}" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "shows a back link and redirects to previous page" do
      header "Referer", "/previous_page"
      expect(response.body).to have_link("Back", href: "/previous_page")
    end

    it "directs back link to home page if no referer header found" do
      expect(response.body).to have_link("Back", href: "/")
    end

    it "has the correct header" do
      expect(response.body).to have_css("h1", text: "#{title}")
    end

    it "displays the title the same as the main header value" do
      expect(response.body).to have_title "#{title} – GOV.UK"
    end

    it "has the Get Help or Give Feedback section" do
      expect(response.body).to have_css("h2", text: "Get help or give feedback")
    end

    if dont_render_guidance
      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end
end
