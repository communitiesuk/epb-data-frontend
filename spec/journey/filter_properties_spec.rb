# frozen_string_literal: true

shared_context "when awaiting responses" do
end

describe "Journey::FilterProperties", :journey, type: :feature do
  let(:getting_domain) do
    "http://get-energy-performance-data.epb-frontend:9393"
  end

  process_id = nil

  before(:all) do
    output = if ENV["SHOW_SERVER_LOGS"] == "true"
               { out: $stdout, err: $stderr }
             else
               { out: File::NULL, err: File::NULL }
             end

    process_id =
      spawn(
        "rackup",
        "config_test.ru",
        "-q",
        "-o", "127.0.0.1",
        "-p", "9393",
        **output
      )

    # Wait until the Puma server has started up before commencing tests
    loop do
      TCPSocket.new("127.0.0.1", 9393).close
      break
    rescue Errno::ECONNREFUSED
      sleep 0.1
    end
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  context "when downloading all data" do
    before do
      visit "#{getting_domain}/filter-properties?property_type=domestic"
      click_on "Download all"
    end

    it "the response location will be to the pre-signed url" do
      expect(page).to have_current_path(%r{^/full-load/domestic-csv\.zip\?X-Amz-Algorithm=AWS4-HMAC-SHA256&.*})
    end
  end

  context "when selecting council properties" do
    before do
      visit "#{getting_domain}/type-of-properties"
      find("#label-domestic").click
      click_on "Continue"
      find(".govuk-accordion__show-all").click
      select "May", from: "from-month"
      select "2024", from: "from-year"
      la_input = find("input#local-authority")
      la_input.click
      la_input.send_keys("Adur", :enter)
      la_input.send_keys("Birmingham", :enter)
      click_on "Download selected"
    end

    it "shows the expected councils selection" do
      expect(page).to have_content("Adur")
      expect(page).to have_content("Birmingham")
    end
  end

  context "when selecting constituencies" do
    before do
      visit "#{getting_domain}/type-of-properties"
      find("#label-domestic").click
      click_on "Continue"
      find(".govuk-accordion__show-all").click
      select "May", from: "from-month"
      select "2024", from: "from-year"
      find("input#area-2.govuk-radios__input", visible: :all).click
      pc_input = find("input#parliamentary-constituency")
      pc_input.click
      pc_input.send_keys("Ashford", :enter)
      pc_input.send_keys("Barking", :enter)
      click_on "Download selected"
    end

    it "shows the expected constituencies selection" do
      expect(page).to have_content("Ashford")
      expect(page).to have_content("Barking")
    end
  end
end
