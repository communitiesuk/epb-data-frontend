shared_context "when testing the opt out process" do
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

  def visit_login_as_owner
    visit_opt_out_owner
    find("#label-yes").click
    click_button "Continue"
  end

  def set_opt_out_reason_other
    find("#label-epc_other").click
    click_button "Continue"
  end

  def set_name
    fill_in "name", with: "John Test"
    click_button "Continue"
  end

  def set_certificate_details
    fill_in "certificate_number", with: "1234-1234-1234-1234-1234"
    fill_in "address-line1", with: "Test Street"
    fill_in "address-town", with: "London"
    fill_in "address-postcode", with: "TE5 1NG"
    click_button "Continue"
  end
end
