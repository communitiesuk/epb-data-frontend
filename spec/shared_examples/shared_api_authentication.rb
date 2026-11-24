# frozen_string_literal: true

shared_examples "an api restricted path" do |path, method: :get|
  it "returns a redirect the login with no authorisation" do
    send(method, path)
    expect(last_response.status).to eq(method == :get ? 302 : 303)
    expect(last_response.location).to eq "http://example.org/login/authorize?referer=#{CGI.escape(path.lstrip('/'))}"
  end
end
