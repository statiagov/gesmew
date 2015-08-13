require 'spec_helper'

describe "Switching currencies in backend", :type => :feature do
  before do
    create(:base_product, :name => "RoR Mug")
  end

  # Regression test for #2340
  it "does not cause current_order to become nil", inaccessible: true do
    visit gesmew.root_path
    click_link "RoR Mug"
    click_button "Add To Cart"
    # Now that we have an inspection...
    Gesmew::Config[:currency] = "AUD"
    expect { visit gesmew.root_path }.not_to raise_error
  end

end
