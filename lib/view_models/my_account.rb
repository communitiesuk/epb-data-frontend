module ViewModels
  class MyAccount
    def self.get_email_address(session)
      Helper::Session.get_email_from_session(session)
    end

    def self.get_bearer_token(user_info)
      user_info[:bearer_token]
    end

    def self.unsubscribed?(user_info)
      user_info[:opt_out]
    end

    def self.get_subscription_description(user_info)
      if unsubscribed?(user_info)
        I18n.t("my_account.unsubscribed_status_text")
      else
        I18n.t("my_account.subscribed_status_text")
      end
    end
  end
end
