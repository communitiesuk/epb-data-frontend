describe "Acceptance::FilterProperties", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data/filter-properties"
  end

  let(:response) { get local_host }

  let(:valid_response) { post "#{local_host}?#{valid_dates}&#{valid_eff_rating}" }

  let(:valid_dates) do
    "from-year=2023&from-month=January&to-year=2025&to-month=February"
  end
  let(:invalid_dates) do
    "from-year=2025&from-month=January&to-year=2023&to-month=December"
  end
  let(:valid_eff_rating) do
    "ratings[]=A&ratings[]=B"
  end
  let(:valid_postcode) do
    "postcode=SW1A%201AA"
  end

  describe "get .get-energy-certificate-data.epb-frontend/filter-properties" do
    context "when the data access options page is rendered" do
      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "shows a back link" do
        expect(response.body).to have_link "Back", href: "/"
      end

      it "the title to be correct" do
        expect(response.body).to have_selector("h1", text: "Energy Performance Certificates")
      end

      it "the title to be correct for both domestic and non-domestic headers" do
        expected_title = "Energy Performance Certificates"
        expect(response.body).to have_selector("h1", text: expected_title)
      end

      it "shows the correct list of years" do
        expected_years = (2012..2025).map(&:to_s)
        expect(ViewModels::FilterProperties.years).to eq(expected_years)
      end

      it "shows the correct list of months" do
        expected_months = %w[January February March April May June July August September October November December]
        expect(ViewModels::FilterProperties.months).to eq(expected_months)
      end

      it "selects the correct default year and month in the select with id='from-year'" do
        expect(response.body).to have_css("select#from-year option[selected]", text: "2012")
        expect(response.body).to have_css("select#from-month option[selected]", text: "January")
      end

      it "selects the correct default year and month in the select with id='to-year'" do
        expect(response.body).to have_css("select#to-year option[selected]", text: ViewModels::FilterProperties.current_year)
        expect(response.body).to have_css("select#to-month option[selected]", text: ViewModels::FilterProperties.previous_month)
      end

      it "shows the correct list of councils" do
        expected_councils = [
          "Aberdeen City Council",
          "Aberdeenshire Council",
          "Angus Council",
        ]
        expect(ViewModels::FilterProperties.councils).to eq(expected_councils)
      end

      it "shows the correct list of parliamentary constituencies" do
        expected_councils = [
          "Bristol Central",
          "Cities of London and Westminster",
          "Manchester Central",
        ]
        expect(ViewModels::FilterProperties.parliamentary_constituencies).to eq(expected_councils)
      end
    end

    context "when the selected dates are valid" do
      it "returns status 200" do
        expect(valid_response.status).to eq(200)
      end

      it "does not display an error message" do
        expect(valid_response.body).not_to have_text "govuk-form-group--error"
        expect(valid_response.body).not_to have_text "govuk-error-message"
      end
    end

    context "when the selected dates are invalid" do
      let(:invalid_response) { post "#{local_host}?#{invalid_dates}&#{valid_eff_rating}" }

      it "returns status 400" do
        expect(invalid_response.status).to eq(400)
      end

      it "displays an error message" do
        expect(invalid_response.body).to include(
          '<p id="date-error" class="govuk-error-message">',
        )
      end

      it "shows correct required GDS error summary" do
        expect(invalid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(invalid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select a valid date range")
        expect(invalid_response.body).to have_link("Select a valid date range", href: "#date-error")
      end
    end

    context "when the efficiency rating selection is valid" do
      it "returns status 200" do
        expect(valid_response.status).to eq(200)
      end

      it "displays an error message" do
        expect(valid_response.body).not_to include(
          '<p id="eff-rating-error" class="govuk-error-message">',
        )
      end
    end

    context "when the efficiency rating selection is invalid" do
      let(:invalid_response) { post "#{local_host}?#{valid_dates}" }

      it "returns status 400" do
        expect(invalid_response.status).to eq(400)
      end

      it "displays an error message" do
        expect(invalid_response.body).to include(
          '<p id="eff-rating-error" class="govuk-error-message">',
        )
      end

      it "shows correct required GDS error summary" do
        expect(invalid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
        expect(invalid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: "Select at least one rating option")
        expect(invalid_response.body).to have_link("Select at least one rating option", href: "#eff-rating-error")
      end
    end

    context "when the postcode is valid" do
      it "returns status 200" do
        expect(valid_response.status).to eq(200)
      end

      it "displays an error message" do
        expect(valid_response.body).not_to include(
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
        end
      end

      it "shows correct required GDS error summary" do
        invalid_responses.each_with_index do |invalid_response, index|
          expect(invalid_response.body).to have_css("div.govuk-error-summary h2.govuk-error-summary__title", text: "There is a problem")
          expect(invalid_response.body).to have_css("div.govuk-error-summary__body ul.govuk-list li:first a", text: error_messages[index])
          expect(invalid_response.body).to have_link(error_messages[index], href: "#postcode-error")
        end
      end
    end
  end
end
