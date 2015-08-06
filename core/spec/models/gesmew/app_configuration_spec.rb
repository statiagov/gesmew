require 'spec_helper'

describe Gesmew::AppConfiguration, :type => :model do

  let (:prefs) { Rails.application.config.gesmew.preferences }

  it "should be available from the environment" do
    prefs.layout = "my/layout"
    expect(prefs.layout).to eq "my/layout"
  end

  it "should be available as Gesmew::Config for legacy access" do
    Gesmew::Config.layout = "my/layout"
    expect(Gesmew::Config.layout).to eq "my/layout"
  end
end

