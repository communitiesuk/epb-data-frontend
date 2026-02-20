shared_examples "when checking GDS error messages" do
  it "shows an error message" do
    expect(page).to have_css("h2", text: "There is a problem")
  end
end

shared_examples "when checking 404 error message" do
  it "shows an error message" do
    expect(page).to have_css("h1", text: "Page not found")
  end
end
