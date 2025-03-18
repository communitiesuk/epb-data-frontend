describe "Acceptance::FilterPropertiesPage", type: :feature do
  include RSpecFrontendServiceMixin

  let(:local_host) do
    "http://get-energy-performance-data/filter-properties"
  end

  let(:response) { get local_host }

  let(:valid_dates) do
    "from-year=2023&from-month=January&to-year=2025&to-month=February"
  end
  let(:invalid_dates) do
    "from-year=2025&from-month=January&to-year=2023&to-month=December"
  end
  let(:valid_eff_rating) do
    "ratings[]=A&ratings[]=B"
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
      let(:valid_response) { post "#{local_host}?#{valid_dates}&#{valid_eff_rating}" }

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
    end

    context "when the efficiency rating selection is valid" do
      let(:valid_response) { post "#{local_host}?#{valid_dates}&#{valid_eff_rating}" }

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
    end
  end
end
