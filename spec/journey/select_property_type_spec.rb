# frozen_string_literal: true

xdescribe "Journey::SelectPropertyType", :journey, type: :feature do
  let(:getting_domain) do
    "http://get-energy-performance-data.epb-frontend:9393"
  end

  process_id = nil

  before(:all) do
    process =
      IO.popen(
        [
          "rackup",
          "config_test.ru",
          "-q",
          "-o",
          "127.0.0.1",
          "-p",
          "9393",
          { err: %i[child out] },
        ],
      )
    process_id = process.pid

    # Wait until the Puma server has started up before commencing tests
    loop do
      break if process.readline.include?("Listening on http://127.0.0.1:9393")
    end
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when selecting a property type" do
    before do
      visit "#{getting_domain}/type-of-properties"
      find("#label-domestic").click
      click_on "Continue"
    end

    it "shows the correct header for the filter property page" do
      expect(page).to have_content "Download all data"
    end
  end

  context "when not selecting a property type" do
    before do
      visit "#{getting_domain}/type-of-properties"
      click_on "Continue"
    end

    it "shows the error message" do
      expect(page).to have_content(/There is a problem/)
    end
  end
end
