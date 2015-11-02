require 'gesmew_core'
require 'gesmew/sample'

module GesmewSample
  class Engine < Rails::Engine
    engine_name 'gesmew_sample'

    # Needs to be here so we can access it inside the tests
    def self.load_samples
      Gesmew::Sample.load_sample("establishments")
      Gesmew::Sample.load_sample("rubrics")
    end
  end
end
