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

  before do
    allow(download_size_use_case).to receive(:execute).and_return(123)
    allow(send_sns_use_case).to receive(:execute)
    post "/filter-properties?property_type=domestic&#{valid_dates}&#{valid_eff_rating}&area-type=local-authority&local-authority[]=Select+all"
    follow_redirect!
  end

  describe "get .get-energy-certificate-data.epb-frontend/request-received-confirmation" do
    context "when the request received confirmation page is rendered" do
      it "calls the, download use case with correct arguments" do
        expect(download_size_use_case).to have_received(:execute).with(
          hash_including(
            postcode: nil,
            council: nil,
            constituency: nil,
            eff_rating: %w[A B],
            date_start: "2023-01-01",
            date_end: "2025-02-28",
          ),
        )
      end

      it "calls the sns use_case with correct arguments" do
        expect(send_sns_use_case).to have_received(:execute).with hash_including(area_type: "local-authority",
                                                                                 email_address: "epbtest@mctesty.com",
                                                                                 include_recommendations: nil,
                                                                                 property_type: "domestic",
                                                                                 efficiency_ratings: %w[A B])
      end

      it "returns status 200" do
        expect(last_response.status).to eq(200)
      end

      it "shows a back link" do
        expect(last_response.body).to have_link "Back", href: "/filter-properties?property_type=domestic"
      end

      it "the title to be correct" do
        expect(last_response.body).to have_selector("h2", text: "Request received")
        expect(last_response.body).to have_selector("p.govuk-body", text: "This may take up to 15 minutes to be delivered to your inbox.")
      end

      it "shows correct content for the requested data" do
        expect(last_response.body).to have_css(".govuk-body", text: "You requested data for:")
        expect(last_response.body).to have_css(".govuk-body", text: "Energy Performance Certificates")
        expect(last_response.body).to have_css(".govuk-body", text: "January 2023 - February 2025")
        expect(last_response.body).to have_css(".govuk-body", text: "Energy Efficiency Rating A, B")
      end
    end
  end
end
