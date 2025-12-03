shared_examples "when checking an authorisation for opt-out restricted endpoints" do |end_point:|
  context "when the user is not authenticated for /opt-out/#{end_point}" do
    before do
      allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "User is not authenticated")
    end

    let(:response) { get "/opt-out/#{end_point}" }

    it "returns status 302" do
      expect(response.status).to eq(302)
    end

    it "redirects to the login page" do
      expect(response.location).to include("/login?referer=opt-out")
    end
  end
end
