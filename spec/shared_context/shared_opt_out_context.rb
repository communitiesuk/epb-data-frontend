shared_context "when testing the opt out process" do
  def visit_opt_out_reason
    visit url
    click_link "Continue"
  end

  def visit_opt_out_owner
    visit_opt_out_reason
    within_fieldset "Why would you like to opt out your EPC?" do
      choose "Other / Prefer not to say", allow_label_click: true
    end
    click_button "Continue"
  end

  def visit_opt_out_occupant
    visit_opt_out_owner
    within_fieldset "Are you the legal owner of the property that you want to opt out?" do
      choose "No", allow_label_click: true
    end
    click_button "Continue"
  end

  def visit_login_as_owner
    visit_opt_out_owner
    within_fieldset "Are you the legal owner of the property that you want to opt out?" do
      choose "Yes", allow_label_click: true
    end
    click_button "Continue"
    find "h1", text: "Create your GOV.UK One Login or sign in"
  end

  def set_opt_out_reason_other
    within_fieldset "Why would you like to opt out your EPC?" do
      choose "Other / Prefer not to say", allow_label_click: true
    end
    click_button "Continue"
  end

  def set_name
    fill_in "Full name", with: "John Test"
    click_button "Continue"
  end

  def set_certificate_details
    fill_in "Certificate number", with: "1234-1234-1234-1234-1234"
    within_fieldset "Address" do
      fill_in "Address line 1", with: "Test Street"
      fill_in "Town or city", with: "London"
      fill_in "Postcode", with: "TE5 1NG"
    end
    click_button "Continue"
  end
end
