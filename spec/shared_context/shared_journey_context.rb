shared_context "when setting up journey tests" do
  def set_oauth_cookies
    state = "test-state-#{SecureRandom.hex(8)}"
    nonce = "test-nonce-#{SecureRandom.hex(8)}"

    page.driver.browser.manage.add_cookie(name: "state", value: state)
    page.driver.browser.manage.add_cookie(name: "nonce", value: nonce)
  end
end
