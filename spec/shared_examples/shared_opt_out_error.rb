shared_examples "when checking error messages" do
  it "shows an error message" do
    expect(page).to have_css("h2", text: "There is a problem")
  end
end
