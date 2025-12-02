module Controller
  class OptOutController < BaseController
    get "/opt-out" do
      status 200
      set_layout
      erb :'opt_out/start'
    end

    get "/opt-out/incorrect-epc" do
      status 200
      set_layout
      erb :'opt_out/incorrect_epc'
    end

    def set_layout
      @hide_my_account = true
    end
  end
end
