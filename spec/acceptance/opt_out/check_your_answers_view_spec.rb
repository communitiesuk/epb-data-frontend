describe "Acceptance::OptOutCheckYourAnswers", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/check-your-answers" do
    let(:response) { get "#{base_url}/opt-out/check-your-answers" }

    before do
      allow(Helper::Session).to receive_messages(
        is_user_authenticated?: true,
        get_email_from_session: "test@email.com",
        get_opt_out_session_value: "Some Address Detail",
      )
      allow(ViewModels::OptOut).to receive_messages(
        get_full_name_from_session: "Some Name",
        get_email_from_session: "test@email.com",
        get_relationship_to_the_property: "Owner",
        get_certificate_number_from_session: "EPC1234567890",
        get_address_detail_from_session: "Some Address Detail",
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
        expect(response.body).to have_css("input#confirmation[value=checked]")
      end

      it "has a warning message" do
        expect(response.body).to have_css("div.govuk-warning-text", text: "Opting out an EPC for the purpose of securing grant funding is fraud.")
      end

      it "has a submit button" do
        expect(response.body).to have_button("Submit request")
      end

      context "when the user is not authenticated" do
        before { allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "User is not authenticated") }

        it "redirects to the sign-in page" do
          get "#{base_url}/opt-out/check-your-answers"

          expect(last_response.status).to eq(302)
          expect(last_response.headers["Location"]).to include("/login")
        end
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

    context "when the data is missing from the session" do
      before do
        allow(Helper::Session).to receive_messages(
          get_email_from_session: nil,
          get_opt_out_session_value: nil,
        )

        allow(ViewModels::OptOut).to receive(:get_relationship_to_the_property).and_call_original
        allow(ViewModels::OptOut).to receive(:get_email_from_session).and_call_original
        allow(ViewModels::OptOut).to receive(:get_full_name_from_session).and_call_original
        allow(ViewModels::OptOut).to receive(:get_certificate_number_from_session).and_call_original
        allow(ViewModels::OptOut).to receive(:get_address_detail_from_session).and_call_original
      end

      it "redirects to the opt-out start page" do
        get "#{base_url}/opt-out/check-your-answers"

        expect(last_response.status).to eq(302)
        expect(last_response.headers["Location"]).to eq("#{base_url}/opt-out")
      end

      context "when the relationship to the property is missing" do
        it "raises MissingOptOutValues error" do
          expect { ViewModels::OptOut.get_relationship_to_the_property(nil) }.to raise_error(Errors::MissingOptOutValues)
        end
      end

      context "when email is missing from session" do
        it "raises MissingOptOutValues error" do
          expect { ViewModels::OptOut.get_email_from_session(nil) }.to raise_error(Errors::MissingOptOutValues)
        end
      end

      context "when full name is missing from session" do
        it "raises MissingOptOutValues error" do
          expect { ViewModels::OptOut.get_full_name_from_session(nil) }.to raise_error(Errors::MissingOptOutValues)
        end
      end

      context "when certificate number is missing from session" do
        it "raises MissingOptOutValues error" do
          expect { ViewModels::OptOut.get_certificate_number_from_session(nil) }.to raise_error(Errors::MissingOptOutValues)
        end
      end

      context "when address details are missing from session" do
        context "when address line 1 or postcode are missing" do
          let(:session) { { opt_out: { name: "Some Name" } } }

          it "raises MissingOptOutValues error" do
            expect { ViewModels::OptOut.get_address_detail_from_session(session, :address_line1) }.to raise_error(Errors::MissingOptOutValues)
            expect { ViewModels::OptOut.get_address_detail_from_session(session, :address_postcode) }.to raise_error(Errors::MissingOptOutValues)
          end
        end

        context "when any other address details are missing" do
          let(:session) { { opt_out: { name: "Some Name", address_line1: "Some Address", address_postcode: "Some Postcode" } } }

          it "does not raise a MissingOptOutValues error" do
            expect { ViewModels::OptOut.get_address_detail_from_session(session, :address_town) }.not_to raise_error
          end
        end
      end
    end

    context "when submitting the form" do
      it "redirects to the received page" do
        response = post "#{base_url}/opt-out/check-your-answers", { confirmation: "checked" }
        expect(response.status).to eq(302)
        expect(response.headers["Location"]).to eq("#{base_url}/opt-out/received")
      end

      context "when the confirmation checkbox is not checked" do
        it "re-renders the check your answers page with an error message" do
          response = post "#{base_url}/opt-out/check-your-answers"
          expect(response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
          expect(response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "You must check the box to submit the request")
          expect(response.body).to have_link("You must check the box to submit the request", href: "#confirmation-error")
        end
      end
    end
  end
end
