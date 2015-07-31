require 'spec_helper'

describe "gesmew/checkout/_summary.html.erb", :type => :view do
  # Regression spec for #4223
  it "does not use the @order instance variable" do
    order = stub_model(Gesmew::Order)
    expect do
      render :partial => "gesmew/checkout/summary", :locals => {:order => order}
    end.not_to raise_error
  end
end