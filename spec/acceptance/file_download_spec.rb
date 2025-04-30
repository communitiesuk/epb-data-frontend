describe "Acceptance::FileDownload", type: :feature do
  include RSpecFrontendServiceMixin

  describe "get .get-energy-certificate-data.epb-frontend/download" do
    let(:local_host) do
      "http://get-energy-performance-data/download"
    end

    let(:file_name) do
      "output/323eee63-6c56-4e77-9e36-7699f4cb240.csv"
    end

    let(:response) do
      get "#{local_host}?file=#{file_name}"
    end

    it "returns status the redirect status" do
      expect(response.status).to eq(302)
    end

    it "the response location will be to the pre-signed url" do
      expect(response.headers["location"]).to include("https://user-data.s3.us-stubbed-1.amazonaws.com/#{file_name}?X-Amz-Algorithm=AWS4-HMAC")
    end

    context "when no file is found" do
      let(:response) do
        get "#{local_host}?file=none.csv"
      end

      let(:use_case) do
        instance_double(UseCase::GetPresignedUrl)
      end

      let(:app) do
        container = instance_double(Container, get_object: use_case)

        Rack::Builder.new do
          use Rack::Session::Cookie, secret: "test" * 16
          run Controller::FilterPropertiesController.new(container: container)
        end
      end

      around do |example|
        original_stage = ENV["STAGE"]
        ENV["STAGE"] = "mock"
        example.run
        ENV["STAGE"] = original_stage
      end

      after do
        ENV.delete("STAGE")
      end

      before do
        allow(use_case).to receive(:execute).and_raise(Errors::FileNotFound)
        # get "#{local_host}?file=none.csv"
      end

      it "raises a 404" do
        expect(response.status).to eq(404)
      end
    end
  end

  describe "get .get-energy-certificate-data.epb-frontend/download/all" do
    let(:local_host) do
      "http://get-energy-performance-data/download/all"
    end

    let(:property_type) do
      "domestic"
    end

    let(:response) do
      get "#{local_host}?property_type=#{property_type}"
    end

    it "returns status the redirect status" do
      expect(response.status).to eq(302)
    end

    it "the response location will be to the pre-signed url" do
      expect(response.headers["location"]).to include("https://user-data.s3.us-stubbed-1.amazonaws.com/#{property_type}/full_load/#{property_type}.zip?X-Amz-Algorithm=AWS4-HMAC")
    end

    context "when no file is found" do
      let(:response) do
        get "#{local_host}?property_type=none"
      end

      let(:use_case) do
        instance_double(UseCase::GetPresignedUrl)
      end

      let(:app) do
        container = instance_double(Container, get_object: use_case)

        Rack::Builder.new do
          use Rack::Session::Cookie, secret: "test" * 16
          run Controller::FilterPropertiesController.new(container: container)
        end
      end

      around do |example|
        original_stage = ENV["STAGE"]
        ENV["STAGE"] = "mock"
        example.run
        ENV["STAGE"] = original_stage
      end

      after do
        ENV.delete("STAGE")
      end

      before do
        allow(use_case).to receive(:execute).and_raise(Errors::FileNotFound)
        # get "#{local_host}?file=none.csv"
      end

      it "raises a 404" do
        expect(response.status).to eq(404)
      end
    end
  end
end
