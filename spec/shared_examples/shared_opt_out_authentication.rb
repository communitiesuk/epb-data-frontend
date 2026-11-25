# frozen_string_literal: true

shared_examples "an opt-out restricted path" do |path, method: :get|
  before do
    allow(Helper::Session).to receive(:is_user_authenticated?).and_raise(Errors::AuthenticationError, "User is not authenticated")
  end

  it "returns a redirect the login with no authorisation" do
    send(method, path)
    expect(last_response.status).to eq(method == :get ? 302 : 303)
    expect(last_response.location).to eq "http://example.org/login?referer=opt-out"
  end
end
