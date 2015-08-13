require 'spec_helper'

describe "gesmew/checkout/_summary.html.erb", :type => :view do
  # Regression spec for #4223
  it "does not use the @inspection instance variable" do
    inspection = stub_model(Gesmew::Inspection)
    expect do
      render :partial => "gesmew/checkout/summary", :locals => {:inspection => inspection}
    end.not_to raise_error
  end
end