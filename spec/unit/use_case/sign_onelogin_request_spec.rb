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
          "b25jZSIsInZ0ciI6IltcIkNsLkNtXCJdIiwidWlfbG9jYWxlcyI6ImVuIn0.LWsYQFZnvbw8qq0bUb_bLweonQjN" \
          "6Fo-NKTNjY4xYDAPIKyHBltPMyI0qK-e_RnnJoL-3x917Yvzxkj055zS0Vga6VilJRa6u8_CYyqZqxVjZ7QhwzqH" \
          "ogRuXLfRjNI7u99YSyF3JQPGfMNwLCrxUIBESkhFXw_gH1-nFvaovw67hb48ilUaiMs-7g75eQsFRWrp2p-XYWCm" \
          "TJwgjiLNr_MK4k3pSpuC96Gz3fdY5OSRIWuXy5qiXPj55TASLRaZ3-_T-emh011JgqklXB3ONEnsd9mxYyYuue7R" \
          "0V10Blo5WFl4YwWx6dvW2RpRs30fe0Wisz4X5Xk41IvKhWBNDw"

        expect(result).to eq(expected_result.force_encoding("ASCII-8BIT"))
      end
    end
  end
end
