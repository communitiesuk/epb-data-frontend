describe "Acceptance::RequestReceivedConfirmation", type: :feature do
  include RSpecFrontendServiceMixin
  let(:local_host) do
    "http://get-energy-performance-data/request-received-confirmation"
  end
  let(:valid_dates) do
    "from-year=2023&from-month=January&to-year=2025&to-month=February"
  end
  let(:valid_eff_rating) do
    "ratings[]=A&ratings[]=B"
  end

  before do
    allow(Helper::Session).to receive(:get_email_from_session).and_return("placeholder@email.com")
    allow(Helper::Session).to receive(:get_session_value).and_call_original
    allow(Helper::Session).to receive(:get_session_value).with(anything, :download_count).and_return(123_456)
  end

  describe "get .get-energy-certificate-data.epb-frontend/request-received-confirmation" do
    context "when the referer is missing" do
      before do
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "returns 403 Forbidden" do
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
        expect(last_response.status).to eq(403)
        expect(last_response.body).to include("Access Forbidden")
      end
    end

    context "when the referer path is invalid" do
      before do
        header "Referer", "http://get-energy-performance-data/other-path"
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "returns 403 Forbidden" do
        expect(last_response.status).to eq(403)
        expect(last_response.body).to include("Access Forbidden")
      end
    end

    context "when the referer host is invalid" do
      before do
        header "Referer", "http://localhost/filter-properties"
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "returns 403 Forbidden" do
        expect(last_response.status).to eq(403)
        expect(last_response.body).to include("Access Forbidden")
      end
    end

    context "when the request received confirmation page is rendered" do
      before do
        header "Referer", "http://get-energy-performance-data/filter-properties"
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "returns status 200" do
        expect(last_response.status).to eq(200)
      end

      it "shows a back link" do
        expect(last_response.body).to have_link "Back", href: "/filter-properties?property_type=domestic"
      end

      it "the title to be correct" do
        expect(last_response.body).to have_selector("h2", text: "Request received")
        expect(last_response.body).to have_selector("p.govuk-body", text: "This may take a few minutes to be delivered to your inbox.")
      end

      it "shows correct content for the requested data" do
        expect(last_response.body).to have_css(".govuk-body", text: "You requested data for:")
        expect(last_response.body).to have_css(".govuk-body", text: "Energy Performance Certificates")
        expect(last_response.body).to have_css(".govuk-body", text: "January 2023 - February 2025")
        expect(last_response.body).to have_css(".govuk-body", text: "Energy Efficiency Rating A, B")
        expect(last_response.body).to have_css(".govuk-body", text: "Your request contains 123,456 certificates.")
      end

      context "when the request contains more than 999 certificates" do
        before do
          get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
        end

        it "adds commas to the displayed number" do
          expect(last_response.body).to have_css(".govuk-body", text: "Your request contains 123,456 certificates.")
        end
      end
    end

    context "when the request received is for domestic property" do
      before do
        header "Referer", "http://get-energy-performance-data/filter-properties"
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "shows the correct value for the size of the file" do
        expect(last_response.status).to eq(200)
        expect(last_response.body).to have_css(".govuk-body", text: "The estimated download size is 121.01 MB.")
      end
    end

    context "when the request received is for non-domestic property" do
      before do
        header "Referer", "http://get-energy-performance-data/filter-properties"
        get "#{local_host}?property_type=non_domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "shows the correct value for the size of the file" do
        expect(last_response.status).to eq(200)
        expect(last_response.body).to have_css(".govuk-body", text: "The estimated download size is 48.4 MB.")
      end
    end

    context "when the request received is for display property" do
      before do
        header "Referer", "http://get-energy-performance-data/filter-properties"
        get "#{local_host}?property_type=display&#{valid_dates}&#{valid_eff_rating}"
      end

      it "shows the correct value for the size of the file" do
        expect(last_response.status).to eq(200)
        expect(last_response.body).to have_css(".govuk-body", text: "The estimated download size is 43.4 MB.")
      end
    end

    context "when the request if failing to get download count from session" do
      before do
        allow(Helper::Session).to receive(:get_session_value).with(anything, :download_count).and_return(nil)
        header "Referer", "http://get-energy-performance-data/filter-properties"
        get "#{local_host}?property_type=domestic&#{valid_dates}&#{valid_eff_rating}"
      end

      it "returns status 500" do
        expect(last_response.status).to eq(500)
      end

      it "raises MissingDownloadCount error" do
        expect { Helper::Session.get_download_count_from_session(nil) }.to raise_error(Errors::MissingDownloadCount)
      end
    end
  end
end
