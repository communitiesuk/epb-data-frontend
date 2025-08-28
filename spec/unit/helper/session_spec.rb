describe Helper::Session do
  let(:session) { { "email_address": "test@email.com" } }
  let(:key) { :test_key }

  context "when setting a session value" do
    it "sets the value in the session" do
      described_class.set_session_value(session, key, "value")
      expect(session[key]).to eq("value")
    end
  end

  context "when checking if a session key exists" do
    it "returns true if the key exists" do
      session[key] = "value"
      result = described_class.exists?(session, key)
      expect(result).to be true
    end

    it "returns false if the key does not exist" do
      result = described_class.exists?(session, key)
      expect(result).to be false
    end
  end

  context "when getting a session value" do
    it "returns the value if the key exists" do
      session[key] = "value"
      value = described_class.get_session_value(session, key)
      expect(value).to eq("value")
    end

    it "returns nil if the key does not exist" do
      value = described_class.get_session_value(session, key)
      expect(value).to be_nil
    end
  end

  context "when clearing the session" do
    it "clears all values from the session" do
      session[key] = "value"
      described_class.clear_session(session)
      expect(session).to be_empty
    end
  end

  describe "#get_email_from_session" do
    it "returns the email if it exists in the session" do
      email = described_class.get_email_from_session(session)
      expect(email).to eq("test@email.com")
    end
  end

  describe "#is_user_authenticated?" do
    context "when session is not nil" do
      it "returns true if email is set" do
        result = described_class.is_user_authenticated?(session)
        expect(result).to be(true)
      end

      it "raises an AuthenticationError if email is not set" do
        session[:email_address] = nil
        expect { described_class.is_user_authenticated?(session) }.to raise_error(Errors::AuthenticationError, "User email is not set in session")
      end
    end

    context "when session is nil" do
      it "raises an AuthenticationError" do
        expect { described_class.is_user_authenticated?(nil) }.to raise_error(Errors::AuthenticationError, "Session is not available")
      end
    end
  end
end
