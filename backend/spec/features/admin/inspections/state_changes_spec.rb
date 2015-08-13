require 'spec_helper'

describe "Inspection - State Changes", type: :feature do
  stub_authorization!

  let!(:inspection) { create(:order_with_line_items) }

  context "for completed inspection" do
    before do
      inspection.next!
      visit gesmew.admin_order_state_changes_path(inspection)
    end
    it 'are viewable' do
      within_row(1) do
        within('td:nth-child(1)') { expect(page).to have_content('Inspection') }
        within('td:nth-child(2)') { expect(page).to have_content('Cart') }
        within('td:nth-child(3)') { expect(page).to have_content('Address') }
      end
    end
  end
end
