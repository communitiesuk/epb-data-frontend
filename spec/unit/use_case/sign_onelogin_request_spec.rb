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
        expected_result = "eyJhbGciOiJSUzI1NiJ9.IntcImF1ZFwiOlwidGVzdF9hdWRcIixcImlzc1wiOlwidGVzdF9jbGllbnRfaWRcIixcInJlc3BvbnNlX3R5cG" \
          "VcIjpcImNvZGVcIixcImNsaWVudF9pZFwiOlwidGVzdF9jbGllbnRfaWRcIixcInJlZGlyZWN0X3VyaVwiOlwiaHR0cHM6Ly9leGFtcGxlLmNvbS9yZWRpcmVjdF" \
          "wiLFwic2NvcGVcIjpcIm9wZW5pZCBlbWFpbFwiLFwic3RhdGVcIjpcInRlc3Rfc3RhdGVcIixcIm5vbmNlXCI6XCJ0ZXN0X25vbmNlXCIsXCJ2dHJcIjpcIltcXF" \
          "wiQ2wuQ00uUDJcXFwiXVwiLFwidWlfbG9jYWxlc1wiOlwiZW5cIixcImNsYWltc1wiOntcInVzZXJpbmZvXCI6e1wiaHR0cHM6Ly92b2NhYi5hY2NvdW50Lmdvdi" \
          "51ay92MS9jb3JlSWRlbnRpdHlKV1RcIjpudWxsfX19Ig.M3-RZvHz-o2Oi3VG49DzO0WQRqEGEUFT2i0LYU3-bh0g2HJqbzricjIhPpZ_17vG2GqXcKrfm04eKV-" \
          "AlRJbs8CY0AEMlNjyHptwAhFNxnvngDoXA4LwOYvvwfRx55TU2lYBGoxp48EB0hFRiY6VijG4yXif89wBnKX8eBiV5gFFsl9LTdW43H8Hilhd4AY1z342K4sdAjk" \
          "9NylXIgqNtmy3uq2Jcjl8zKWtYUkbIwzZDlxLvc54hxV_2SXL5OhuMtAln2ARR_8yMK6jBKPak5yRJxMeQBdyeXUm-rvMYHKccofYxSzRRICL-eNteU0HkEJwbp9" \
          "2l6zQXb_ejFqeJg"
        expect(result).to eq(expected_result.force_encoding("ASCII-8BIT"))
      end
    end
  end
end
