# frozen_string_literal: true

describe Helper::ValidateSession do
  let(:session) do
    {
      opt_out_name: "Tester",
      opt_out_certificate_number: "1234-7890-1234-7890-1234-7890",
      opt_out_address_line1: "123 Test Street",
      opt_out_address_line2: "",
      opt_out_address_town: "London",
      opt_out_address_postcode: "TE5 7ER",
      opt_out_owner: "yes",
      opt_out_occupant: nil,
    }
  end
  let(:validate_session) { described_class.new(session) }

  before do
    allow(Helper::Session).to receive(:get_email_from_session).and_return("test@example.com")
  end

  context "when the data session is present" do
    context "when the name is present" do
      it "does not raise an error" do
        expect { validate_session.validate_full_name }.not_to raise_error
      end
    end

    context "when the certificate number is present" do
      it "does not raise an error" do
        expect { validate_session.validate_certificate_number }.not_to raise_error
      end
    end

    context "when the address details is present" do
      it "does not raise an error" do
        expect { validate_session.validate_address(:opt_out_address_line1) }.not_to raise_error
        expect { validate_session.validate_address(:opt_out_address_line2) }.not_to raise_error
        expect { validate_session.validate_address(:opt_out_address_town) }.not_to raise_error
        expect { validate_session.validate_address(:opt_out_address_postcode) }.not_to raise_error
      end
    end

    context "when the relationship to property is present" do
      it "does not raise an error" do
        expect { validate_session.validate_relationship_to_the_property }.not_to raise_error
      end
    end

    context "when the email is present" do
      it "does not raise an error" do
        expect { validate_session.validate_email }.not_to raise_error
      end
    end
  end

  context "when the data is missing from the session" do
    before do
      allow(Helper::Session).to receive(:get_session_value).and_return(nil)
    end

    context "when the name is missing" do
      it "raises a MissingOptOutValues error" do
        expect { validate_session.validate_full_name }.to raise_error(Errors::MissingOptOutValues)
      end
    end

    context "when the certificate number is missing" do
      it "raises a MissingOptOutValues error" do
        expect { validate_session.validate_certificate_number }.to raise_error(Errors::MissingOptOutValues)
      end
    end

    context "when the address details is missing" do
      context "when address line 1 or postcode are missing" do
        it "raises MissingOptOutValues error" do
          expect { validate_session.validate_address(:opt_out_address_line1) }.to raise_error(Errors::MissingOptOutValues)
          expect { validate_session.validate_address(:opt_out_address_postcode) }.to raise_error(Errors::MissingOptOutValues)
        end
      end

      context "when any other address details are missing" do
        it "does not raise a MissingOptOutValues error" do
          expect { validate_session.validate_address(:opt_out_address_line2) }.not_to raise_error
          expect { validate_session.validate_address(:opt_out_address_town) }.not_to raise_error
        end
      end
    end

    context "when the relationship to property is missing" do
      it "raises MissingOptOutValues error" do
        expect { validate_session.validate_relationship_to_the_property }.to raise_error(Errors::MissingOptOutValues)
      end
    end

    context "when the email is missing" do
      it "does not raise an error" do
        allow(Helper::Session).to receive(:get_email_from_session).and_return(nil)
        expect { validate_session.validate_email }.to raise_error(Errors::MissingOptOutValues)
      end
    end
  end
end
