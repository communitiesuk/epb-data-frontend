describe "Acceptance::OptOutIncorrectEpc", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/incorrect-epc" do
    let(:response) { get "#{base_url}/opt-out/incorrect-epc" }

    context "when there is session data" do
      before do
        allow(Helper::Session).to receive(:get_session_value).with(anything, anything).and_call_original
        allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out_incorrect_epc).and_return(true)
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "contains the correct h1 header" do
        expect(response.body).to have_selector("h1", text: "What to do if your EPC is incorrect")
      end

      it "shows a back link and redirects to previous page" do
        expect(response.body).to have_link("Back", href: "/opt-out/reason")
      end
    end

    context "when there is no session data" do
      let(:response) { get "#{base_url}/opt-out/incorrect-epc" }

      before do
        allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out_incorrect_epc).and_return(nil)
      end

      it "returns status 302" do
        expect(response.status).to eq(302)
      end

      it "completes POST and redirects to opt-out start page" do
        expect(response.location).to eq("#{base_url}/opt-out")
      end
    end
  end
end
