describe "Acceptance::OptOutCheckYourAnswers", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/check-your-answers" do
    let(:response) { get "#{base_url}/opt-out/check-your-answers" }

    before do
      allow(Helper::Session).to receive_messages(
        get_email_from_session: "test@email.com",
        get_full_name_from_session: "Some Name",
        get_owner_from_opt_out_session_key: "yes",
        get_occupant_from_opt_out_session_key: nil,
        get_certificate_number_from_session: "EPC1234567890",
      )
      allow(ViewModels::OptOut).to receive_messages(
        get_full_name_from_session: "Some Name",
        get_email_from_session: "test@email.com",
        get_relationship_to_the_property: "Owner",
        get_certificate_number_from_session: "EPC1234567890",
      )
    end

    context "when the page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "contains the correct page title" do
        expect(response.body).to have_selector("h1", text: "Check your answers before submitting your request")
      end

      it "does not show a back link" do
        expect(response.body).not_to have_link("Back")
      end

      it "shows the correct content for personal details section" do
        expect(response.body).to have_selector("h1", text: "Personal details")
        expect(response.body).to have_selector("dt", text: "Name")
        expect(response.body).to have_selector("dt", text: "Email address")
        expect(response.body).to have_selector("dt", text: "Relationship to the property")
      end

      it "shows the correct content for property details section" do
        expect(response.body).to have_selector("h1", text: "Property details")
        expect(response.body).to have_selector("dt", text: "Certificate number")
        expect(response.body).to have_selector("dt", text: "Property address")
      end

      it "shows the correct content for confirmation section" do
        expect(response.body).to have_selector("h1", text: "Confirmation")
        expect(response.body).to have_css("input#confirmation[value=confirmation]")
      end

      it "has a warning message" do
        expect(response.body).to have_css("div.govuk-warning-text", text: "Opting out an EPC for the purpose of securing grant funding is fraud.")
      end

      it "has a submit button" do
        expect(response.body).to have_button("Submit request")
      end
    end

    context "when the data is passed from session to the summary table" do
      it "shows the full name" do
        expect(response.body).to have_css("#full-name-value", text: "Some Name")
      end

      it "shows the email address" do
        expect(response.body).to have_css("#email-address-value", text: "test@email.com")
      end

      it "shows the relationship to the property" do
        expect(response.body).to have_css("#property-relationship-value", text: "Owner")
      end

      it "shows the certificate number" do
        expect(response.body).to have_css("#certificate-number-value", text: "EPC1234567890")
      end
    end
  end
end
