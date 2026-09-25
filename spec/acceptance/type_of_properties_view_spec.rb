describe "Acceptance::TypeOfProperties", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/type-of-properties"
  end

  describe "post .get-energy-certificate-data.epb-frontend/type-of-properties" do
    context "when the user is not authenticated" do
      before do
        allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "Session is not available")
      end

      it "redirects to /login/authorize using status 303" do
        post local_host
        expect(last_response.status).to eq(303)
        expect(last_response.location).to include "/login/authorize?referer=type-of-properties"
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/type-of-properties" do
    before do
      allow(Helper::Session).to receive(:is_user_authenticated?).and_return(true)
    end

    context "when the type of properties page is rendered" do
      before do
        get local_host
      end

      it "returns status 200" do
        expect(last_response.status).to eq(200)
      end

      it "shows a back link" do
        expect(last_response.body).to have_link "Back", href: "/data-access-options"
      end

      it "has the correct form header" do
        expect(last_response.body).to have_css("h1", text: "What type of certificates do you want data on?")
      end

      it "displays the title the same as the main header value" do
        expect(last_response.body).to have_title "What type of certificates do you want data on? – GOV.UK"
      end
    end

    context "when submitting with a property type" do
      it "routes to the domestic page with the domestic property_type param" do
        post "http://get-energy-performance-data/type-of-properties", { property_type: "domestic" }
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/filter-properties?property_type=domestic")
      end

      it "routes to the non-domestic page with the non-domestic property_type param" do
        post "http://get-energy-performance-data/type-of-properties", { property_type: "non-domestic" }
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/filter-properties?property_type=non-domestic")
      end

      it "routes to the display page with the display property_type param" do
        post "http://get-energy-performance-data/type-of-properties", { property_type: "display" }
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/filter-properties?property_type=display")
      end
    end

    context "when submitting without deciding a property type" do
      it "contains the required GDS error summary" do
        post "http://get-energy-performance-data/type-of-properties"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(last_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select a type of certificate")
        expect(last_response.body).to have_link("Select a type of certificate", href: "#property-type-error")
        expect(last_response.body).to have_title "Error: What type of certificates do you want data on? – GOV.UK", exact: true
      end
    end

    context "when submitting with an invalid property type" do
      it "contains the required GDS error summary" do
        post "http://get-energy-performance-data/type-of-properties", { property_type: "foo" }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(last_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select a type of certificate")
        expect(last_response.body).to have_link("Select a type of certificate", href: "#property-type-error")
        expect(last_response.body).to have_title "Error: What type of certificates do you want data on? – GOV.UK", exact: true
      end
    end

    context "when the user is authenticated" do
      before { allow(Helper::Session).to receive(:is_user_authenticated?).and_return(true) }

      it "allows access to the type of properties page" do
        get local_host
        expect(last_response.body).to include("What type of certificates do you want data on?")
      end
    end

    context "when the user is not authenticated" do
      before do
        allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "User is not authenticated")
      end

      it "redirects to the OneLogin login page" do
        get local_host
        expect(last_response).to be_redirect
        expect(last_response.location).to eq("http://get-energy-performance-data/login/authorize?referer=type-of-properties")
      end
    end
  end
end
