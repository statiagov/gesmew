require 'spec_helper'

describe "Reports", :type => :feature do
  stub_authorization!

  context "visiting the admin reports page" do
    it "should have the right content" do
      visit gesmew.admin_path
      click_link "Reports"
      click_link "Sales Total"

      expect(page).to have_content("Sales Totals")
      expect(page).to have_content("Item Total")
      expect(page).to have_content("Adjustment Total")
      expect(page).to have_content("Sales Total")
    end
  end

  context "searching the admin reports page" do
    before do
      inspection = create(:inspection)
      inspection.update_columns({:adjustment_total => 100})
      inspection.completed_at = Time.now
      inspection.save!

      inspection = create(:inspection)
      inspection.update_columns({:adjustment_total => 200})
      inspection.completed_at = Time.now
      inspection.save!

      #incomplete inspection
      inspection = create(:inspection)
      inspection.update_columns({:adjustment_total => 50})
      inspection.save!

      inspection = create(:inspection)
      inspection.update_columns({:adjustment_total => 200})
      inspection.completed_at = 3.years.ago
      inspection.created_at = 3.years.ago
      inspection.save!

      inspection = create(:inspection)
      inspection.update_columns({:adjustment_total => 200})
      inspection.completed_at = 3.years.from_now
      inspection.created_at = 3.years.from_now
      inspection.save!
    end

    it "should allow me to search for reports" do
      visit gesmew.admin_path
      click_link "Reports"
      click_link "Sales Total"

      fill_in "q_completed_at_gt", :with => 1.week.ago
      fill_in "q_completed_at_lt", :with => 1.week.from_now
      click_button "Search"

      expect(page).to have_content("$300.00")
    end
  end
end
