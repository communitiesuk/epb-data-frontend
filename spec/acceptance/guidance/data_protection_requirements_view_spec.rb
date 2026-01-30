describe "Acceptance::DataProtectionRequirements", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance/data-protection-requirements" do
    let(:path) { "/guidance/data-protection-requirements" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
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

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Data protection requirements")
        expect(response.body).to have_css(
          "p",
          text: /In order to adhere to the conditions of the Data Protection Act 2018 and the General Data Protection Regulation, MHCLG retains the email address of those who access the data\./,
        )
      end

      it "has the correct content for data protection act section" do
        expect(response.body).to have_css("h2", text: "Data Protection Act 2018")
        expect(response.body).to have_link("Information Commissioner's Office", href: "https://ico.org.uk/")
      end

      it "has the correct content for personal data misuse section" do
        expect(response.body).to have_css("h2", text: "How to report misuse of personal data")
        expect(response.body).to have_link("Information Commissioner’s Office", href: "https://ico.org.uk/")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end
end
