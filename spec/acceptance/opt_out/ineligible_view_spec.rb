describe "Acceptance::OptOutIneligible", type: :feature do
  include RSpecFrontendServiceMixin

  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/opt-out/ineligible" do
    let(:response) { get "#{base_url}/opt-out/ineligible" }

    context "when there is session data" do
      before do
        allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out_owner).and_return("no")
        allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out_occupant).and_return("no")
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      context "when the page is rendered" do
        it "has the correct title" do
          expect(response.body).to have_css("h1", text: "You are not eligible to opt out")
        end

        it "has the correct text" do
          expect(response.body).to have_css("p", text: "You must own or live in the property to opt-out an EPC.")
        end
      end
    end

    context "when there is no session data" do
      let(:response) { get "#{base_url}/opt-out/ineligible" }

      before do
        allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out_owner).and_return(nil)
        allow(Helper::Session).to receive(:get_session_value).with(anything, :opt_out_occupant).and_return(nil)
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
