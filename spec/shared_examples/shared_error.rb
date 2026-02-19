shared_examples "when checking error messages" do
  it "shows a GDS error message" do
    expect(page).to have_css("h2", text: "There is a problem")
  end
end

shared_examples "when checking 500 error message" do
  it "shows an error message" do
    expect(page).to have_css("h1", text: "Sorry, there is a problem with the service")
  end
end
