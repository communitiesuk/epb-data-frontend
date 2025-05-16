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
        expected_result = "@\\\e~\xEEAs\xCD!\xD9L\xEE\xF4\xDB\xC0&^\x94K\x8A\u001F{C^%\xD0Z\xE3\xF9\xAA3\xEE\xAC%\v'V~\xFF\u0015\xB1\xFD\xEC" \
          "\xE9\xFB\xB5!+?\xCF0\xA0\xA6CY\n\xACAA\xE4Ŭ\xD8d\u0004v\xC94\xDB8z\xC0uB$\xC2\xFD\xA9pV3\xDD~W\x81\x83\x81\xED" \
          "\xB6\xB3\xA4\x9Em;[ۢV\xAF\xB6\xA9b\x9A\xAB5\u0016\xE1Ü\xF6\xB0\xC2S\xB0\xD1~\u007F\xDF;\xC3\\\u0016\xA9\x8D\e" \
          "\xCEu:\xB2\u0002\xBBa\xF8\x99\xE9\xF4\xA7\u0019\nU\xA722u8CM\x8F\x88\xAB\xC6:5\rsE\xA1yF\xD7Ĥ\b\xB6\xECȹGN" \
          "\xC3\u0019\xC7Ey\x94襵Eb\x9C\xA1D\x91y\xFFP\b\u000F\xD2\xFB?\x81l\vYk\xAA4OJ\u0018\xFA!\xCB\xDF\xE0\x9A\xD4" \
          "\xC2R\xBF\xB9Ҭ\xDCtO35\u0012\xE5\u0012\x93=\t(AL\xA4\nX\u0012\xAC\xE6g#\xCD\"\xC5m\xC8\xE5\x9E\u001E\xD9s\x87" \
          "\xD5^\xCF]\f\t\xEC\u001A"
        expect(result).to eq(expected_result.force_encoding("ASCII-8BIT"))
      end
    end
  end
end
