shared_context "when testing the opt out process" do
  def set_user_login
    state = "test-state-#{SecureRandom.hex(8)}"
    nonce = "test-nonce-#{SecureRandom.hex(8)}"

    page.driver.browser.manage.add_cookie(name: "state", value: state)
    page.driver.browser.manage.add_cookie(name: "nonce", value: nonce)
  end

  def visit_opt_out_reason
    visit url
    click_link "Continue"
  end

  def visit_opt_out_owner
    visit_opt_out_reason
    find("#label-epc_other").click
    click_button "Continue"
  end

  def visit_opt_out_occupant
    visit_opt_out_owner
    find("#label-no").click
    click_button "Continue"
  end

  def visit_login
    visit_opt_out_owner
    find("#label-yes").click
    click_button "Continue"
  end
end
