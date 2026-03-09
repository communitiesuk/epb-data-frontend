module ViewModels
  class MyAccount
    def self.get_email_address(session)
      Helper::Session.get_email_from_session(session)
    end

    def self.get_bearer_token(user_info)
      user_info[:bearer_token]
    end

    def self.get_opt_out(user_info)
      user_info[:opt_out]
    end

    def self.get_opt_out_description(user_info)
      if get_opt_out(user_info)
        I18n.t("my_account.opt_out_enabled_text")
      else
        I18n.t("my_account.opt_out_disabled_text")
      end
    end
  end
end
