describe "Acceptance::GuidancePage", type: :feature do
  include RSpecFrontendServiceMixin
  let(:base_url) { "http://get-energy-performance-data" }

  describe "get .get-energy-certificate-data.epb-frontend/guidance" do
    let(:path) { "/guidance" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Guidance")
      end

      it "has the correct content under the title" do
        expect(response.body).to have_css("p", text: "You can use these resources to help you understand and use energy certificate data.")
      end

      it "has the correct content for understanding the data" do
        expect(response.body).to have_css("h2", text: "Understanding the data")
        expect(response.body).to have_css("p", text: "Information on how the data is formatted and produced.")
        expect(response.body).to have_link("Linking certificates to recommendations", href: "/linking-certificates-to-recommendations")
        expect(response.body).to have_link("How the data is produced", href: "/how-the-data-is-produced")
        expect(response.body).to have_link("Changes to the format and methodology", href: "/changes-to-the-format-and-methodology")
        expect(response.body).to have_link("Data limitations and exclusions", href: "/data-limitations")
      end

      it "has the correct content for publishing and usage restrictions" do
        expect(response.body).to have_css("h2", text: "Publishing and usage restrictions")
        expect(response.body).to have_css("p", text: "Information on the restrictions that affect how the data is published and how you can use it.")
        expect(response.body).to have_link("Licensing restrictions", href: "/licensing-restrictions")
        expect(response.body).to have_link("Data protection", href: "/data-protection")
      end

      it "has the correct content for developer apis" do
        expect(response.body).to have_css("h2", text: "Developer APIs")
        expect(response.body).to have_css("p", text: "Information on using a developer API.")
        expect(response.body).to have_link("API guidance", href: "/api/api-guidance")
        expect(response.body).to have_link("API technical documentation", href: "/api-technical-documentation")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "has the correct MHCLG contact email" do
        expect(response.body).to have_content("mhclg.digital-services@communities.gov.uk")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/linking-certificates-to-recommendations" do
    let(:path) { "/linking-certificates-to-recommendations" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Linking certificates to recommendations")
      end

      it "has the correct content under the title" do
        expect(response.body).to have_css("p", text: "The method to link certificates to their recommendations varies depending on how the data is accessed:")
      end

      it "has the correct content for CSV download section" do
        expect(response.body).to have_css("p", text: "For domestic EPC and commercial EPC data, the certificate numbers can be used to identify certificates and to link them with their recommendations.")
      end

      it "has the correct content for API section" do
        expect(response.body).to have_css("p", text: "For domestic EPC data, the recommendation reports are included in the EPCs.")
        expect(response.body).to have_css("p", text: "For commercial EPC data, the certificate numbers can be used to fetch the recommendation reports.")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/how-the-data-is-produced" do
    let(:path) { "/how-the-data-is-produced" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "How the data is produced")
      end

      it "has the correct content for section titles" do
        expect(response.body).to have_css("h2", text: "Why energy certificates are created")
        expect(response.body).to have_css("h2", text: "How energy certificates are produced")
        expect(response.body).to have_css("h2", text: "Data release frequency")
        expect(response.body).to have_css("h2", text: "Unique Property Reference Numbers (UPRNs)")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/changes-to-the-format-and-methodology" do
    let(:path) { "/changes-to-the-format-and-methodology" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Changes to the format and methodology")
      end

      it "has the correct content for certificate changes section" do
        expect(response.body).to have_css("h2", text: "Certificate changes")
        expect(response.body).to have_css("p", text: "There have been multiple version changes which affect how domestic and non-domestic EPCs and DECs are formatted.")
        expect(response.body).to have_css("p", text: "You can find JSON Schema describing the different certificate versions on GitHub.")
        expect(response.body).to have_link("GitHub", href: "https://github.com/communitiesuk/epb-data-warehouse/tree/main/spec/fixtures/json_samples")
      end

      it "has the correct content for regulatory changes section" do
        expect(response.body).to have_css("h2", text: "Regulatory changes")
        expect(response.body).to have_css("li", text: "1 October 2008 – The requirement for DECs came into effect for buildings that are over 1,000 square meters, occupied by public authorities and frequently visited by the public.")
        expect(response.body).to have_css("li", text: "9 January 2013 – The floor area size threshold for DECs was lowered to buildings over 500 square meters.")
        expect(response.body).to have_css("li", text: "9 July 2015 – The floor area size threshold for DECs was lowered to buildings over 250 square meters.")
      end

      it "has the correct content for publishing changes section" do
        expect(response.body).to have_css("h2", text: "Publishing changes")
        expect(response.body).to have_css("li", text: "September 2020 – EPC data was migrated to a new register.")
        expect(response.body).to have_css("li", text: "November 2021 – UPRNs (Unique Property Reference Numbers) were added to the data.")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/licensing-restrictions" do
    let(:path) { "/licensing-restrictions" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Licensing restrictions")
      end

      it "has the correct content for non-address data section" do
        expect(response.body).to have_css("h2", text: "Non-Address Data")
        expect(response.body).to have_link("Open Government Licence v3.0", href: "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
      end

      it "has the correct content for survey and copyright section" do
        expect(response.body).to have_css("h2", text: "Ordnance Survey and Royal Mail Copyright and Database Right Notice")
        expect(response.body).to have_link("Further information about these exceptions can be found here", href: "https://www.gov.uk/guidance/exceptions-to-copyright")
        expect(response.body).to have_link("PricingLicensing@os.uk", href: "mailto:PricingLicensing@os.uk")
        expect(response.body).to have_link("address.management@royalmail.com", href: "mailto:address.management@royalmail.com")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/data-protection" do
    let(:path) { "/data-protection" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Data protection")
      end

      it "has the correct content for registration section" do
        expect(response.body).to have_css("h2", text: "Registration")
        expect(response.body).to have_css("p", text: "In order to adhere to the conditions of the Data Protection Act 2018 and the General Data Protection
          Regulation, MHCLG retains the email address of those who access the data.")
      end

      it "has the correct content for data protection act section" do
        expect(response.body).to have_css("h2", text: "Data Protection Act 2018")
        expect(response.body).to have_link("Information Commissioner's Office", href: "https://ico.org.uk/")
      end

      it "has the correct content for personal data misuse section" do
        expect(response.body).to have_css("h2", text: "How to report misuse of personal data")
        expect(response.body).to have_link("Information Commissioner’s Office (ICO)", href: "https://ico.org.uk/")
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/data-limitations" do
    let(:path) { "/data-limitations" }
    let(:response) { get "#{base_url}#{path}" }

    context "when the start page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link and redirects to previous page" do
        header "Referer", "/previous_page"
        expect(response.body).to have_link("Back", href: "/previous_page")
      end

      it "directs back link to home page if no referer header found" do
        expect(response.body).to have_link("Back", href: "/")
      end

      it "has the correct title" do
        expect(response.body).to have_css("h1", text: "Data limitations and exclusions")
      end

      it "has the correct section titles" do
        expect(response.body).to have_css("h2", text: "Representativeness")
        expect(response.body).to have_css("h2", text: "Date availability")
        expect(response.body).to have_css("h2", text: "Data quality")
        expect(response.body).to have_css("h2", text: "Boundary changes")
        expect(response.body).to have_css("h2", text: "What data is excluded")
      end

      it "displays the anomalies table with ten rows" do
        expect(response.body).to have_css("table.govuk-table")
        expect(response.body).to have_css("tbody.govuk-table__body tr", count: 10)
      end

      it "has the Get Help or Give Feedback section" do
        expect(response.body).to have_css("h2", text: "Get help or give feedback")
      end

      it "does not render content for guidance under the Get Help section" do
        expect(response.body).not_to have_content("Visit the guidance page for information on:")
      end
    end
  end
end
