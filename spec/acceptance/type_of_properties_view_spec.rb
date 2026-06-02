describe "Acceptance::TypeOfProperties", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/type-of-properties"
  end

  describe "post .get-energy-certificate-data.epb-frontend/type-of-properties" do
    let(:response) { post local_host }

    context "when the user is not authenticated" do
      before do
        allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "Session is not available")
      end

      it "redirects to /login/authorize using status 303" do
        expect(response.status).to eq(303)
        expect(response.location).to include "/login/authorize?referer=type-of-properties"
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/type-of-properties" do
    let(:response) { get local_host }

    before do
      allow(Helper::Session).to receive(:is_user_authenticated?).and_return(true)
    end

    context "when the type of properties page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/data-access-options"
      end

      it "has the correct form header" do
        expect(response.body).to have_css("h1", text: "What type of certificates do you want data on?")
      end

      it "displays the title the same as the main header value" do
        expect(response.body).to have_title "What type of certificates do you want data on? – GOV.UK"
      end
    end

    context "when submitting with a property type" do
      let(:domestic_response) do
        post "http://get-energy-performance-data/type-of-properties", { property_type: "domestic" }
      end

      let(:non_domestic_response) do
        post "http://get-energy-performance-data/type-of-properties", { property_type: "non-domestic" }
      end

      it "routes to the domestic page with the domestic property_type param" do
        expect(domestic_response.status).to eq(302)
        expect(domestic_response.location).to include("/filter-properties?property_type=domestic")
      end

      it "routes to the non-domestic page with the non-domestic property_type param" do
        expect(non_domestic_response).to be_redirect
        expect(non_domestic_response.location).to include("/filter-properties?property_type=non-domestic")
      end
    end

    context "when submitting without deciding a property type" do
      let(:response) do
        post "http://get-energy-performance-data/type-of-properties"
      end

      it "contains the required GDS error summary" do
        expect(response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select a type of certificate")
        expect(response.body).to have_link("Select a type of certificate", href: "#property-type-error")
      end
    end

    context "when the user is authenticated" do
      before { allow(Helper::Session).to receive(:is_user_authenticated?).and_return(true) }

      it "allows access to the type of properties page" do
        expect(response.body).to include("What type of certificates do you want data on?")
      end
    end

    context "when the user is not authenticated" do
      before do
        allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "User is not authenticated")
      end

      it "redirects to the OneLogin login page" do
        expect(response).to be_redirect
        expect(response.location).to eq("http://get-energy-performance-data/login/authorize?referer=type-of-properties")
      end
    end
  end
end
