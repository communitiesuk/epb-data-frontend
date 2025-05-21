describe "Acceptance::FilterProperties", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data/filter-properties"
  end

  let(:response) { get local_host }

  let(:valid_response) { post "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}" }

  let(:valid_dates) do
    "from-year=2023&from-month=January&to-year=2025&to-month=February"
  end
  let(:invalid_dates) do
    "from-year=2024&from-month=February&to-year=2023&to-month=December"
  end
  let(:valid_eff_rating) do
    "ratings[]=A&ratings[]=B"
  end
  let(:valid_postcode) do
    "postcode=SW1A%201AA"
  end

  let(:download_size_use_case) do
    instance_double(UseCase::GetDownloadSize)
  end

  let(:send_sns_use_case) do
    instance_double(UseCase::SendDownloadRequest)
  end

  let(:app) do
    fake_container = instance_double(Container, get_object: download_size_use_case)
    allow(fake_container).to receive(:get_object).with(:send_download_request_use_case).and_return(send_sns_use_case)

    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "test" * 16
      run Controller::FilterPropertiesController.new(container: fake_container)
    end
  end

  around do |example|
    original_stage = ENV["STAGE"]
    ENV["STAGE"] = "mock"
    example.run
    ENV["STAGE"] = original_stage
  end

  describe "get .get-energy-certificate-data.epb-frontend/filter-properties" do
    context "when the data access options page is rendered" do
      before do
        Timecop.freeze(Time.utc(2025, 4, 1))
      end

      after do
        Timecop.return
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/type-of-properties"
      end

      it "shows the correct title for domestic" do
        response = get "#{local_host}?property_type=domestic"
        expect(response.body).to have_selector("h1", text: "Energy Performance Certificates")
      end

      it "does not show the efficiency rating filter for non-domestic and public properties" do
        property_types = %w[non_domestic public_buildings]

        property_types.each do |property_type|
          response = get "#{local_host}?property_type=#{property_type}"
          expect(response.body).not_to have_css("#eff-rating-section.govuk-accordion__section")
        end
      end

      it "shows the efficiency rating filter for domestic properties" do
        response = get "#{local_host}?property_type=domestic"
        expect(response.body).to have_css("#eff-rating-section.govuk-accordion__section")
      end

      it "selects the correct default year and month in the select with id='from-year'" do
        expect(response.body).to have_css("select#from-year option[selected]", text: "2012")
        expect(response.body).to have_css("select#from-month option[selected]", text: "January")
      end

      it "selects the correct default year and month in the select with id='to-year'" do
        expect(response.body).to have_css("select#to-year option[selected]", text: "2025")
        expect(response.body).to have_css("select#to-month option[selected]", text: "March")
      end

      it "shows all efficiency ratings selected by default for domestic properties" do
        response = get "#{local_host}?property_type=domestic"
        expect(response.body).to have_css("input#ratings-A[value=A][checked]")
        expect(response.body).to have_css("input#ratings-B[value=B][checked]")
        expect(response.body).to have_css("input#ratings-C[value=C][checked]")
        expect(response.body).to have_css("input#ratings-D[value=D][checked]")
        expect(response.body).to have_css("input#ratings-E[value=E][checked]")
        expect(response.body).to have_css("input#ratings-F[value=F][checked]")
        expect(response.body).to have_css("input#ratings-G[value=G][checked]")
      end

      it "shows a select of councils" do
        expect(response.body).to have_css(".govuk-select#local-authority")
      end

      it "shows a select of parliamentary constituencies" do
        expect(response.body).to have_css(".govuk-select#parliamentary-constituency")
      end
    end

    context "when the selected dates are valid" do
      before do
        allow(download_size_use_case).to receive(:execute).and_return(123)
        allow(send_sns_use_case).to receive(:execute)
      end

      it "returns status 302" do
        expect(valid_response.status).to eq(302)
      end

      it "does not display an error message" do
        expect(valid_response.body).not_to have_text "govuk-form-group--error"
        expect(valid_response.body).not_to have_text "govuk-error-message"
      end
    end

    context "when the selected dates are invalid" do
      let(:invalid_response) { post "#{local_host}?property_type=domestic&#{invalid_dates}&#{valid_eff_rating}" }

      it "returns status 400" do
        expect(invalid_response.status).to eq(400)
      end

      it "displays an error message" do
        expect(invalid_response.body).to include(
          '<p id="date-error" class="govuk-error-message">',
        )
      end

      it "keeps the selected dates in the form" do
        expect(invalid_response.body).to include('<option value="2023" selected>')
        expect(invalid_response.body).to include('<option value="2024" selected>')
        expect(invalid_response.body).to include('<option value="February" selected>')
        expect(invalid_response.body).to include('<option value="December" selected>')
      end

      it "shows correct required GDS error summary" do
        expect(invalid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(invalid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select a valid date range")
        expect(invalid_response.body).to have_link("Select a valid date range", href: "#date-section")
      end
    end

    context "when selecting default filters" do
      let(:default_dates) { "from-month=January&from-year=2012&to-month=#{(Date.today << 1).strftime('%B')}&to-year=#{Date.today.year}" }
      let(:default_area) { "postcode=&local-authority[]=Select+all&parliamentary-constituency[]=Select+all" }
      let(:default_eff_rating) { "ratings[]=A&ratings[]=B&ratings[]=C&ratings[]=D&ratings[]=E&ratings[]=F&ratings[]=G" }
      let(:default_filters) { "#{default_dates}&#{default_area}&#{default_eff_rating}" }
      let(:valid_response_with_default_filters) { post "#{local_host}?property_type=domestic&#{default_filters}" }

      it "redirects to the /download/all endpoint" do
        expect(valid_response_with_default_filters.status).to eq(302)
        expect(valid_response_with_default_filters.headers["Location"]).to eq("http://get-energy-performance-data/download/all?property_type=domestic")
      end
    end

    context "when selecting multiple councils" do
      let(:multiple_councils) { "local-authority[]=Birmingham&local-authority[]=Adur" }
      let(:valid_response_with_multiple_councils) { post "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}&#{multiple_councils}" }

      before do
        allow(download_size_use_case).to receive(:execute).and_return(123)
        allow(send_sns_use_case).to receive(:execute)
      end

      it "returns status 302" do
        expect(valid_response_with_multiple_councils.status).to eq(302)
      end
    end

    context "when selecting multiple constituencies" do
      let(:multiple_constituencies) { "parliamentary-constituency[]=Ashford&parliamentary-constituency[]=Cardiff" }
      let(:valid_response_with_multiple_constituencies) { post "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}&#{multiple_constituencies}" }

      before do
        allow(download_size_use_case).to receive(:execute).and_return(123)
        allow(send_sns_use_case).to receive(:execute)
      end

      it "returns status 302" do
        expect(valid_response_with_multiple_constituencies.status).to eq(302)
      end
    end

    context "when the postcode is valid" do
      let(:valid_response_with_postcode) { post "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}&#{valid_postcode}" }

      before do
        allow(download_size_use_case).to receive(:execute).and_return(123)
        allow(send_sns_use_case).to receive(:execute)
      end

      it "returns status 302" do
        expect(valid_response_with_postcode.status).to eq(302)
      end

      it "displays an error message" do
        expect(valid_response_with_postcode.body).not_to include(
          '<p id="postcode-error" class="govuk-error-message">',
        )
      end
    end

    context "when the postcode is invalid" do
      let(:invalid_postcodes) do
        [
          "#{local_host}?#{valid_dates}&#{valid_eff_rating}&area-type=postcode",
          "#{local_host}?#{valid_dates}&#{valid_eff_rating}&area-type=postcode&postcode=ABCD12345",
          "#{local_host}?#{valid_dates}&#{valid_eff_rating}&area-type=postcode&postcode=SW1A 1A$",
        ]
      end

      let(:error_messages) do
        [
          "Enter a full UK postcode in the format LS1 4AP",
          "Enter a valid UK postcode in the format LS1 4AP",
          "Enter a valid UK postcode using only letters and numbers in the format LS1 4AP",
        ]
      end

      let(:invalid_responses) do
        invalid_postcodes.map { |invalid_postcode| post invalid_postcode }
      end

      it "returns status 400" do
        invalid_responses.each do |invalid_response|
          expect(invalid_response.status).to eq(400)
        end
      end

      it "displays an error message" do
        invalid_responses.each do |invalid_response|
          expect(invalid_response.body).to include(
            '<p id="postcode-error" class="govuk-error-message">',
          )
          expect(invalid_response.body).to have_css(
            "#conditional-area-type-postcode .govuk-form-group.govuk-form-group--error",
          )
        end
      end

      it "shows correct required GDS error summary" do
        invalid_responses.each_with_index do |invalid_response, index|
          expect(invalid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
          expect(invalid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: error_messages[index])
          expect(invalid_response.body).to have_link(error_messages[index], href: "#area-type-section")
        end
      end
    end

    context "when the efficiency rating selection is valid" do
      before do
        allow(download_size_use_case).to receive(:execute).and_return(123)
        allow(send_sns_use_case).to receive(:execute)
      end

      it "returns status 302" do
        expect(valid_response.status).to eq(302)
      end

      it "displays an error message" do
        expect(valid_response.body).not_to include(
          '<p id="eff-rating-error" class="govuk-error-message">',
        )
      end
    end

    context "when the efficiency rating selection is invalid" do
      let(:invalid_response) { post "#{local_host}?property_type=domestic&#{valid_dates}" }

      it "returns status 400" do
        expect(invalid_response.status).to eq(400)
      end

      it "keeps the efficiency ratings unchecked when none is selected" do
        expect(invalid_response.body).to have_css("input#ratings-A[value=A]")
        expect(invalid_response.body).to have_css("input#ratings-B[value=B]")
        expect(invalid_response.body).to have_css("input#ratings-C[value=C]")
        expect(invalid_response.body).to have_css("input#ratings-D[value=D]")
        expect(invalid_response.body).to have_css("input#ratings-E[value=E]")
        expect(invalid_response.body).to have_css("input#ratings-F[value=F]")
        expect(invalid_response.body).to have_css("input#ratings-G[value=G]")
      end

      it "displays an error message" do
        expect(invalid_response.body).to include(
          '<p id="eff-rating-error" class="govuk-error-message">',
        )
      end

      it "shows correct required GDS error summary" do
        expect(invalid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(invalid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select at least one rating option")
        expect(invalid_response.body).to have_link("Select at least one rating option", href: "#eff-rating-section")
      end
    end

    context "when no data is found for the selected filters" do
      before do
        allow(download_size_use_case).to receive(:execute).and_raise(Errors::FilteredDataNotFound)
      end

      it "returns status 400" do
        expect(valid_response.status).to eq(400)
      end

      it "shows correct required GDS error summary" do
        expect(valid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(valid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "No certificates were found. Try different filters.")
        expect(valid_response.body).to have_link("No certificates were found. Try different filters.", href: "#filter-properties-header")
      end
    end
  end
end
