describe "Acceptance::RequestReceivedConfirmation", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/request-received-confirmation"
  end
  let(:valid_dates) do
    "from-year=2023&from-month=January&to-year=2025&to-month=February"
  end
  let(:valid_eff_rating) do
    "ratings[]=A&ratings[]=B"
  end

  before do
    post "/filter-properties?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
    follow_redirect!
  end

  describe "get .get-energy-certificate-data.epb-frontend/request-received-confirmation" do
    context "when the request received confirmation page is rendered" do
      it "returns status 200" do
        expect(last_response.status).to eq(200)
      end

      it "shows a back link" do
        expect(last_response.body).to have_link "Back", href: "/filter-properties?property_type=domestic"
      end

      it "the title to be correct" do
        expect(last_response.body).to have_selector("h2", text: "Request received")
        expect(last_response.body).to have_selector("p.govuk-body", text: "This may take up to 15 minutes to be delivered to your inbox.")
      end

      it "shows correct content for the requested data" do
        expect(last_response.body).to have_css(".govuk-body", text: "You requested data for:")
        expect(last_response.body).to have_css(".govuk-body", text: "Energy Performance Certificates")
        expect(last_response.body).to have_css(".govuk-body", text: "January 2023 - February 2025")
        expect(last_response.body).to have_css(".govuk-body", text: "Energy Efficiency Rating A, B")
      end
    end
  end
end
