# frozen_string_literal: true

require_relative "../shared_context/shared_journey_context"

GUIDANCE_PAGES = {
  "Data dictionary" => "/guidance/data-dictionary",
  "Linking certificates to recommendations" => "/guidance/linking-certificates-to-recommendations",
  "How the data is produced" => "/guidance/how-the-data-is-produced",
  "Changes to the format and methodology" => "/guidance/changes-to-the-format-and-methodology",
  "Licensing restrictions" => "/guidance/licensing-restrictions",
  "Data protection requirements" => "/guidance/data-protection-requirements",
  "Data limitations" => "/guidance/data-limitations",
}.freeze

describe "Journey::Guidance", :journey, type: :feature do
  include_context "when setting up journey tests"

  let(:domain) { "http://get-energy-performance-data.epb-frontend:9393" }

  process_id = nil

  before(:all) do
    process = IO.popen(["rackup", "config_test.ru", "-q", "-o", "127.0.0.1", "-p", "9393", { err: %i[child out] }])
    process_id = process.pid
    loop { break if process.readline.include?("Listening on http://127.0.0.1:9393") }
  end

  after(:all) { Process.kill("KILL", process_id) if process_id }

  before do
    visit domain
    set_oauth_cookies
    click_link "Visit the guidance page"
  end

  context "when visiting guidance pages" do
    GUIDANCE_PAGES.each do |heading, path|
      it "displays the correct content for #{heading} page" do
        click_link heading
        expect(page).to have_selector("h1", text: heading)
        expect(page).to have_current_path("#{domain}#{path}")
        expect(page).to have_link("Back", href: "#{domain}/guidance")
      end
    end

    it "displays the correct content API guidance page" do
      click_link "API guidance"
      expect(page).to have_selector("h1", text: "Energy certificate data APIs")
      expect(page).to have_current_path("#{domain}/guidance/energy-certificate-data-apis")
    end
  end
end
