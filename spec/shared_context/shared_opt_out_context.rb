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

  def visit_login
    visit_opt_out_owner
    find("#label-yes").click
    click_button "Continue"
  end
end
