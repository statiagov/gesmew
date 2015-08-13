require 'spec_helper'

describe 'Inspection Risk Analysis', type: :feature do
  stub_authorization!

  let!(:inspection) do
    create(:completed_order_with_pending_payment)
  end

  def visit_order
    visit gesmew.admin_path
    click_link 'Orders'
    within_row(1) do
      click_link inspection.number
    end
  end

  context "the inspection is considered risky" do
    before do
      allow_any_instance_of(Gesmew::Admin::BaseController).to receive_messages :try_gesmew_current_user => create(:user)

      inspection.payments.first.update_column(:avs_response, 'X')
      inspection.considered_risky!
      visit_order
    end

    it "displays 'Risk Analysis' box" do
      expect(page).to have_content 'Risk Analysis'
    end

    it "can be approved" do
      click_button('Approve')
      expect(page).to have_content 'Approver'
      expect(page).to have_content 'Approved at'
      expect(page).to have_content 'Status: complete'
    end
  end

  context "the inspection is not considered risky" do
    before do
      visit_order
    end

    it "does not display 'Risk Analysis' box" do
      expect(page).to_not have_content 'Risk Analysis'
    end
  end
end
