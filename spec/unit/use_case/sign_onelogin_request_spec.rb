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
        expected_result = "eyJhbGciOiJSUzI1NiJ9.eyJhdWQiOiJ0ZXN0X2F1ZCIsImlzcyI6InRlc3RfY2xpZW50X2lkIiwicmVzcG9uc2VfdHlwZSI6ImNvZGUiLCJj" \
          "bGllbnRfaWQiOiJ0ZXN0X2NsaWVudF9pZCIsInJlZGlyZWN0X3VyaSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vcmVkaXJlY3QiLCJzY29wZSI6Im9wZW" \
          "5pZCBlbWFpbCIsInN0YXRlIjoidGVzdF9zdGF0ZSIsIm5vbmNlIjoidGVzdF9ub25jZSIsInZ0ciI6IltcIkNsLkNNLlAyXCJdIiwidWlfbG9jYWxl" \
          "cyI6ImVuIiwiY2xhaW1zIjp7InVzZXJpbmZvIjp7Imh0dHBzOi8vdm9jYWIuYWNjb3VudC5nb3YudWsvdjEvY29yZUlkZW50aXR5SldUIjpudWxsf" \
          "X19.lwlwgFjefn1RLTarxh6pMcBDLF0dIjn5KKRAxDeN5OI1OWBRjRzlftx3WChP9JADmpKDlGx9EA66XkMceQJ9a6zPARXQps6qhQkrmh4cVNZoPz" \
          "mvoYXVFr0bCqhM0nt1uhp9WHnKGk-z9OWWkNzF_BUW-aYZ859dR1k5I-iAK9K41FuvkY87bD2SnBKtwQ8qZodU_VktjSNU38biMqw3wlRpK02NICiH" \
          "1XrnKDNDEc8EGQ-6-frlRGdZurDq5rz8-F12UfIhkQ9QBiIAyktr41ce8bUBhM7SJD4ET-G-d1wTppBJRrTumLvwaumH8o0mCYUuMx6TWRQwEQgCwIZfWA"
        expect(result).to eq(expected_result.force_encoding("ASCII-8BIT"))
      end
    end
  end
end
