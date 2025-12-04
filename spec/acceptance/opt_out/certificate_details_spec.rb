require_relative "../../shared_examples/shared_opt_out_authentication"
describe "Acceptance::OptOutCertificateDetails", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/certificate-details" do
    let(:response) { get "#{base_url}/opt-out/certificate-details" }

    context "when the user is authenticated" do
      before do
        allow(Helper::Session).to receive_messages(
          is_user_authenticated?: true,
          get_email_from_session: "test@email.com",
        )
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "displays the title as expected" do
        expect(response.body).to have_css("h1", text: "Which property would you like to opt out?")
      end

      it "has the label and input for the name" do
        expect(response.body).to have_css("label#certificate-number-label", text: "Certificate number")
        expect(response.body).to have_css("input#certificate-number[type='text']", count: 1)
      end

      it "has the correct Continue button" do
        expect(response.body).to have_css("button[type='submit']", text: "Continue")
      end

      it_behaves_like "when checking an authorisation for opt-out restricted endpoints", end_point: "certificate-details"
    end
  end

  describe "post .get-energy-certificate-data.epb-frontend/opt-out/certificate-details" do
    before do
      allow(Helper::Session).to receive(:set_session_value)
      allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out).and_return({ owner: "yes", name: "Testy McTest" })
    end

    context "when the user is authenticated" do
      before do
        allow(Helper::Session).to receive_messages(
          is_user_authenticated?: true,
          get_email_from_session: "test@email.com",
        )
      end

      context "when all required inputs are provided" do
        let(:response) { post "#{base_url}/opt-out/certificate-details", { certificate_number: "0000-0000-0000-0000-0000", address_line1: "5 Bob Street", address_line2: "Test Grove", address_town: "Testerton", address_postcode: "TE57 1NG" } }

        it "returns status 302" do
          expect(response.status).to eq(302)
        end

        it "redirects to the certificate-details page" do
          expect(response.location).to include("/opt-out/check-your-answers")
        end

        it "has the session value" do
          response
          expect(Helper::Session).to have_received(:set_session_value).with(anything, :opt_out, { owner: "yes", name: "Testy McTest", certificate_number: "0000-0000-0000-0000-0000", address_line1: "5 Bob Street", address_line2: "Test Grove", address_town: "Testerton", address_postcode: "TE57 1NG" })
        end
      end

      context "when the input is empty" do
        let(:response) { post "#{base_url}/opt-out/certificate-details", { certificate_number: " ", address_line1: " ", address_line2: " ", address_town: " ", address_postcode: " " } }

        it "returns status 200" do
          expect(response.status).to eq(200)
        end

        it "displays the error summary" do
          expect(response.body).to have_css("div.govuk-error-summary")
        end

        it "display the certificate number error" do
          expect(response.body).to have_css("p#certificate-number-error", text: /Enter a valid certificate number/)
        end

        it "display the address line 1 error" do
          expect(response.body).to have_css("p#address-line1-error", text: /Enter the first line of your address/)
        end

        it "display the postcode error" do
          expect(response.body).to have_css("p#address-postcode-error", text: /Enter a valid postcode/)
        end
      end

      context "when the certificate number is not valid" do
        let(:response) { post "#{base_url}/opt-out/certificate-details", { certificate_number: "TEST ERROR", address_line1: "5 Bob Street", address_line2: "Test Grove", address_town: "Testerton", address_postcode: "TE57 1NG" } }

        it "returns status 200" do
          expect(response.status).to eq(200)
        end

        it "displays the error summary" do
          expect(response.body).to have_css("div.govuk-error-summary")
        end

        it "display the selection error" do
          expect(response.body).to have_css("p#certificate-number-error", text: /Enter a valid certificate number/)
        end
      end

      context "when the postcode is not valid" do
        let(:response) { post "#{base_url}/opt-out/certificate-details", { certificate_number: "0000-0000-0000-0000-0000", address_line1: "5 Bob Street", address_line2: "Test Grove", address_town: "Testerton", address_postcode: "BOB" } }

        it "returns status 200" do
          expect(response.status).to eq(200)
        end

        it "displays the error summary" do
          expect(response.body).to have_css("div.govuk-error-summary")
        end

        it "display the selection error" do
          expect(response.body).to have_css("p#address-postcode-error", text: /Enter a valid postcode/)
        end
      end
    end
  end
end
