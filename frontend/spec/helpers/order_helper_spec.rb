require 'spec_helper'

module Gesmew
  describe Gesmew::OrdersHelper, :type => :helper do
    # Regression test for #2518 + #2323
    it "truncates HTML correctly in establishment description" do
      establishment = double(:description => "<strong>" + ("a" * 95) + "</strong> This content is invisible.")
      expected = "<strong>" + ("a" * 95) + "</strong>..."
      expect(truncated_product_description(establishment)).to eq(expected)
    end
  end
end
