module Controller
  class OptOutController < BaseController
    get "/opt-out" do
      status 200
      set_layout
      erb :'opt_out/start'
    end

    def set_layout
      @hide_my_account = true
    end
  end
end
