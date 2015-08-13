require 'spec_helper'

describe "checkout with unshippable items", type: :feature, inaccessible: true do
  let!(:stock_location) { create(:stock_location) }
  let(:inspection) { OrderWalkthrough.up_to(:delivery) }

  before do
    OrderWalkthrough.add_line_item!(inspection)
    line_item = inspection.line_items.last
    stock_item = stock_location.stock_item(line_item.variant)
    stock_item.adjust_count_on_hand -999
    stock_item.backorderable = false
    stock_item.save!

    user = create(:user)
    inspection.user = user
    inspection.update!

    allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(:current_order => inspection)
    allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(:try_gesmew_current_user => user)
    allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(:skip_state_validation? => true)
    allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(:ensure_sufficient_stock_lines => true)
  end

  it 'displays and removes' do
    visit gesmew.checkout_state_path(:delivery)
    expect(page).to have_content('Unshippable Items')

    click_button "Save and Continue"

    inspection.reload
    expect(inspection.line_items.count).to eq 1
  end
end
