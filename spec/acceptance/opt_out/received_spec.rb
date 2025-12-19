describe "Acceptance::OptOutReceived", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/received" do
    let(:response) { get "#{base_url}/opt-out/received" }

    context "when the user is authenticated" do
      before do
        allow(Helper::Session).to receive_messages(
          is_user_authenticated?: true,
          get_email_from_session: "test@email.com",
          delete_session_key: nil,
        )
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "displays the title as expected" do
        expect(response.body).to have_css("div.govuk-panel--confirmation h1.govuk-panel__title", text: "Request received")
      end

      it "displays the sub heading as expected" do
        expect(response.body).to have_css("h2", text: "What happens next")
      end

      it "clears the opt-out session data" do
        response
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_owner)
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_occupant)
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_name)
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_address_line1)
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_address_line2)
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_address_town)
        expect(Helper::Session).to have_received(:delete_session_key).with(anything, :opt_out_address_postcode)
      end
    end

    context "when the user is not authenticated" do
      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to the login page" do
        expect(response.headers["Location"]).to eq("#{base_url}/login?referer=opt-out")
      end
    end
  end
end
