describe ViewModels::DownloadStartedConfirmation do
  let(:view_model) { described_class }

  describe "#default_end_date" do
    before do
      Timecop.freeze(Time.utc(2026, 6, 15))
    end

    after do
      Timecop.return
    end

    context "when the current month is June" do
      it "returns May" do
        expect(view_model.default_end_date).to eq("January 2012 - May 2026")
      end
    end
  end
end
