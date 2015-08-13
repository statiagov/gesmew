require 'spec_helper'

describe 'inspections', :type => :feature do
  let(:inspection) { OrderWalkthrough.up_to(:complete) }
  let(:user) { create(:user) }

  before do
    inspection.update_attribute(:user_id, user.id)
    inspection.shipments.destroy_all
    allow_any_instance_of(Gesmew::OrdersController).to receive_messages(:try_gesmew_current_user => user)
  end

  it "can visit an inspection" do
    # Regression test for current_user call on inspections/show
    expect { visit gesmew.order_path(inspection) }.not_to raise_error
  end

  it "should display line item price" do
    # Regression test for #2772
    line_item = inspection.line_items.first
    line_item.target_shipment = create(:shipment)
    line_item.price = 19.00
    line_item.save!

    visit gesmew.order_path(inspection)

    # Tests view gesmew/shared/_order_details
    within 'td.price' do
      expect(page).to have_content "19.00"
    end
  end

  it "should have credit card info if paid with credit card" do
    create(:payment, :inspection => inspection)
    visit gesmew.order_path(inspection)
    within '.payment-info' do
      expect(page).to have_content "Ending in 1111"
    end
  end

  it "should have payment method name visible if not paid with credit card" do
    create(:check_payment, :inspection => inspection)
    visit gesmew.order_path(inspection)
    within '.payment-info' do
      expect(page).to have_content "Check"
    end
  end

  # Regression test for #2282
  context "can support a credit card with blank information" do
    before do
      credit_card = create(:credit_card)
      credit_card.update_column(:cc_type, '')
      payment = inspection.payments.first
      payment.source = credit_card
      payment.save!
    end

    specify do
      visit gesmew.order_path(inspection)
      within '.payment-info' do
        expect { find("img") }.to raise_error(Capybara::ElementNotFound)
      end
    end
  end

  it "should return the correct title when displaying a completed inspection" do
    visit gesmew.order_path(inspection)

    within '#order_summary' do
      expect(page).to have_content("#{Gesmew.t(:inspection)} #{inspection.number}")
    end
  end
end
