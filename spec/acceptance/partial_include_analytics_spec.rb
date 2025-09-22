require "sinatra/cookies"

describe "Partial include analytics", type: :feature do
  include RSpecFrontendServiceMixin

  let(:url) do
    "http://get-energy-performance-data"
  end

  before do
    allow(CGI).to receive(:h).and_return("123456")
  end

  context "when the cookie_consent cookie is null" do
    let(:response) do
      get url
    end

    it "returns 200" do
      expect(response.status).to be(200)
    end

    it "includes the partial in the layout" do
      expect(response.body).to include("gtag/js?id=G-H8EVD5HY3G")
    end
  end

  context "when the cookie_consent cookie is true" do
    let(:response) do
      get url, {}, "HTTP_COOKIE" => "cookie_consent=true"
    end

    it "returns 200" do
      expect(response.status).to be(200)
    end

    it "includes the partial in the layout" do
      expect(response.body).to include("gtag/js?id=G-H8EVD5HY3G")
    end

    it "include the gtag script" do
      expect(response.body).to include("gtag()")
    end
  end

  context "when the cookie_consent cookie is false" do
    let(:response) do
      get url, {}, "HTTP_COOKIE" => "cookie_consent=false"
    end

    it "returns 200" do
      expect(response.status).to be(200)
    end

    it "does not include the partial in the layout" do
      expect(response.body).not_to include("gtag/js?id=G-H8EVD5HY3G")
    end

    it "does not include the gtag script" do
      expect(response.body).not_to include("gtag()")
    end
  end

  context "when the google_property is not set" do
    before do
      ENV["GTM_PROPERTY_FINDING"] = nil
    end

    let(:response) do
      get url, {}, "HTTP_COOKIE" => "cookie_consent=true"
    end

    it "returns 200" do
      expect(response.status).to be(200)
    end

    it "does not include the partial in the layout" do
      expect(response.body).not_to include("gtag/js?id=G-H8EVD5HY3G")
    end
  end
end
