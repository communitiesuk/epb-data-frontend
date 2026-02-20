shared_context "when setting up journey tests" do
  def set_oauth_cookies
    state = "test-state-#{SecureRandom.hex(8)}"
    nonce = "test-nonce-#{SecureRandom.hex(8)}"

    page.driver.browser.manage.add_cookie(name: "state", value: state)
    page.driver.browser.manage.add_cookie(name: "nonce", value: nonce)
  end

  def visit_type_of_properties
    visit domain
    set_oauth_cookies
    find("a.govuk-button--start", text: "Start now").click
    visit "#{domain}/type-of-properties"
  end

  def uncheck_efficiency_ratings(ratings: %w[A B C D E F G])
    ratings.each do |rating|
      checkbox = find("#ratings-#{rating}", visible: :all)
      checkbox.click if checkbox.checked?
    end
  end
end
