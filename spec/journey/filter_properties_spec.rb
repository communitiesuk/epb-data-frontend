# frozen_string_literal: true

describe "Journey::FilterProperties", :journey, type: :feature do
  let(:getting_domain) do
    "http://get-energy-performance-data.epb-frontend:9393"
  end

  let(:previous_month) do
    Date::MONTHNAMES[Time.now.month - 1]
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

    nil unless process.readline.include?("port=9393")
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when downloading all data" do
    before do
      visit "#{getting_domain}/filter-properties?property_type=domestic"
      click_on "Download all"
    end

    it "shows the expected destination page content" do
      expect(page).to have_selector("h2", text: "Download started")
    end
  end

  context "when downloading default filtered data for domestic properties" do
    before do
      visit "#{getting_domain}/filter-properties?property_type=domestic"
      click_on "Download selected"
    end

    it "shows the expected page content" do
      expect(page).to have_selector("h2", text: "Request received")
      expect(page).to have_selector("li", text: "Energy Performance Certificates")
      expect(page).to have_selector("li", text: "January 2012 - #{previous_month} 2025")
      expect(page).to have_selector("li", text: "England and Wales")
      expect(page).to have_selector("li", text: "Energy Efficiency Rating A, B, C, D, E, F, G")
    end
  end

  context "when downloading selected filtered data for domestic properties" do
    before do
      visit "#{getting_domain}/filter-properties?property_type=domestic"
      select "May", from: "from-month"
      select "2024", from: "from-year"
      find(".govuk-accordion__show-all").click
      la_input = find("input#local-authority")
      la_input.click
      la_input.send_keys("Adur", :enter)
      click_on "Download selected"
    end

    it "shows the expected page content" do
      expect(page).to have_selector("h2", text: "Request received")
      expect(page).to have_selector("li", text: "Energy Performance Certificates")
      expect(page).to have_selector("li", text: "May 2024 - #{previous_month} 2025")
      expect(page).to have_selector("li", text: "Adur")
      expect(page).to have_selector("li", text: "Energy Efficiency Rating A, B, C, D, E, F, G")
    end
  end

  context "when downloading selected filtered data for domestic properties using multiselect" do
    before do
      visit "#{getting_domain}/filter-properties?property_type=domestic"
      find(".govuk-accordion__show-all").click
      select "May", from: "from-month"
      select "2024", from: "from-year"
    end

    it "shows the expected page content when selecting multiple councils" do
      la_input = find("input#local-authority")
      la_input.click
      la_input.send_keys("Adur", :enter)
      la_input.send_keys("Birmingham", :enter)
      click_on "Download selected"
      expect(page).to have_selector("h2", text: "Request received")
      expect(page).to have_selector("li", text: "Energy Performance Certificates")
      expect(page).to have_selector("li", text: "May 2024 - #{previous_month} 2025")
      expect(page).to have_selector("li", text: "Adur, Birmingham")
      expect(page).to have_selector("li", text: "Energy Efficiency Rating A, B, C, D, E, F, G")
    end

    it "shows the expected page content when selecting multiple constituencies" do
      find("input#area-2.govuk-radios__input", visible: :all).click
      la_input = find("input#parliamentary-constituency")
      la_input.click
      la_input.send_keys("Ashford", :enter)
      la_input.send_keys("Barking", :enter)
      click_on "Download selected"
      expect(page).to have_selector("h2", text: "Request received")
      expect(page).to have_selector("li", text: "Energy Performance Certificates")
      expect(page).to have_selector("li", text: "May 2024 - #{previous_month} 2025")
      expect(page).to have_selector("li", text: "Ashford, Barking")
      expect(page).to have_selector("li", text: "Energy Efficiency Rating A, B, C, D, E, F, G")
    end
  end
end
