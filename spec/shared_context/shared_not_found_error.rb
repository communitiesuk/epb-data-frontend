# frozen_string_literal: true

shared_examples "when checking 404 error message" do
  it "shows an error message" do
    expect(page).to have_css("h1", text: "Page not found")
  end
end
