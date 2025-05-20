describe UseCase::SignOneloginRequest do
  subject(:use_case) { described_class.new }

  let(:use_case_args) do
    {
      client_id: "test_client_id",
      aud: "test_aud",
      state: "test_state",
      nonce: "test_nonce",
      redirect_uri: "https://example.com/redirect",
    }
  end

  describe "#execute" do
    context "when the request is valid" do
      it "returns the signed request" do
        result = use_case.execute(**use_case_args)

        expected_result = "eyJraWQiOiIzNTVhNWMzZC03YTIxLTRlMWUtOGFiOS1hYTE0YzMzZDgzZmIiLCJhbGciOiJSUzI1NiJ9." \
          "eyJhdWQiOiJ0ZXN0X2F1ZCIsImlzcyI6InRlc3RfY2xpZW50X2lkIiwicmVzcG9uc2VfdHlwZSI6ImNvZGUiLCJj" \
          "bGllbnRfaWQiOiJ0ZXN0X2NsaWVudF9pZCIsInJlZGlyZWN0X3VyaSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vcmVk" \
          "aXJlY3QiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCIsInN0YXRlIjoidGVzdF9zdGF0ZSIsIm5vbmNlIjoidGVzdF9u" \
          "b25jZSIsInZ0ciI6IltcIkNsLkNNLlAyXCJdIiwidWlfbG9jYWxlcyI6ImVuIiwiY2xhaW1zIjp7InVzZXJpbmZv" \
          "Ijp7Imh0dHBzOi8vdm9jYWIuYWNjb3VudC5nb3YudWsvdjEvY29yZUlkZW50aXR5SldUIjpudWxsfX19.gDTJd2Dh" \
          "yP5wx8SOVVwCFzlT_Y6H5cSJ69c4bisr_Yt3-D3r8AGuhigUIW1XRhb0VRTO5I9cjj9pYNrIcJ8T1SK-1Rv_kAVu" \
          "5KJvVMYI-8rSRdl2R9Up_JnLbn7p3gHGOfp-R1vzAWkmKTYWxWnDvqOHzSp-NpPi3tC-WEFPvOqJWB4ENp0_NSWw" \
          "FljNiZVUvHvz6hWX2msJWHcT_XRuL9zkUFb_1tKuAcbe7DEman6q516INXyw72O0voVhXblPT5cZlG9vFSDcjQVM" \
          "ewzhyGnkNWQFEMYwuA5Mz6d9331Sa9zAkSHZ4V8veklWl9l6nBvn0RwAJM58wiYDzgEwUQ"

        expect(result).to eq(expected_result.force_encoding("ASCII-8BIT"))
      end
    end
  end
end
