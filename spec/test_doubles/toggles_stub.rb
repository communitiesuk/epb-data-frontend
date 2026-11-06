class TogglesStub
  def self.enable(features = nil)
    domain = ENV["EPB_UNLEASH_URI"]

    WebMock.stub_request(:post, /#{domain}.*/)
    WebMock
      .stub_request(:get, /#{domain}.*/)
      .to_return(
        status: 200,
        body:
          JSON.generate(
            {
              version: 1,
              features: construct_features_body(features),
            },
          ),
      )
  end

  private_class_method def self.construct_features_body(features)
    features&.map do |(feature, state)|
      {
        name: feature,
        description: "Test feature #{feature}",
        enabled: state,
        strategies: [{ name: "default" }],
        variants: nil,
        createdAt: "2019-11-14T14:24:44.277Z",
      }
    end
  end
end
