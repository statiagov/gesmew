require 'gesmew_core'
require 'gesmew/sample'

module GesmewSample
  class Engine < Rails::Engine
    engine_name 'gesmew_sample'

    # Needs to be here so we can access it inside the tests
    def self.load_samples
      Gesmew::Sample.load_sample("payment_methods")
      Gesmew::Sample.load_sample("shipping_categories")
      Gesmew::Sample.load_sample("shipping_methods")
      Gesmew::Sample.load_sample("tax_categories")
      Gesmew::Sample.load_sample("tax_rates")

      Gesmew::Sample.load_sample("products")
      Gesmew::Sample.load_sample("taxons")
      Gesmew::Sample.load_sample("option_values")
      Gesmew::Sample.load_sample("product_option_types")
      Gesmew::Sample.load_sample("product_properties")
      Gesmew::Sample.load_sample("prototypes")
      Gesmew::Sample.load_sample("variants")
      Gesmew::Sample.load_sample("stock")
      Gesmew::Sample.load_sample("assets")

      Gesmew::Sample.load_sample("orders")
      Gesmew::Sample.load_sample("adjustments")
      Gesmew::Sample.load_sample("payments")
    end
  end
end
