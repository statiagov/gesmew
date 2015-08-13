require 'spec_helper'

describe "Inspection Listing", type: :feature, js:true do
  stub_authorization!

  let!(:user_a) { create(:admin_user, email: 'a@example.com') }
  let!(:user_b) { create(:admin_user, email: 'b@example.com') }

  let(:inspection_1) do
    create :inspection,
      created_at: 1.day.from_now,
      completed_at: 1.day.from_now,
      considered_risky: true,
      number: "I100"
  end

  let(:inspection_2) do
    create :inspection,
      created_at: 1.day.ago,
      completed_at: 1.day.ago,
      number: "I200"
  end

  before do
    user_a.inspections << inspection_1
    user_b.inspections << inspection_2
    user_a.inspections << inspection_2
    user_b.inspections << inspection_1

    visit gesmew.admin_inspections_path
  end

  describe "listing inspections" do
    it "should list existing inspections" do
      within_row(1) do
        expect(column_text(2)).to eq "I100"
        expect(find("td:nth-child(3)")).to have_css '.label-considered_risky'
        # expect(column_text(4)).to eq "cart"
      end

      within_row(2) do
        expect(column_text(2)).to eq "I200"
        expect(find("td:nth-child(3)")).to have_css '.label-considered_safe'
      end
      sleep 20.seconds
    end

    it "should be able to sort the inspections listing" do
      # default is completed_at desc
      within_row(1) { expect(page).to have_content("R100") }
      within_row(2) { expect(page).to have_content("R200") }

      click_link "Completed At"

      # Completed at desc
      within_row(1) { expect(page).to have_content("R200") }
      within_row(2) { expect(page).to have_content("R100") }

      within('table#listing_orders thead') { click_link "Number" }

      # number asc
      within_row(1) { expect(page).to have_content("R100") }
      within_row(2) { expect(page).to have_content("R200") }
    end
  end

  describe "searching inspections" do
    it "should be able to search inspections" do
      fill_in "q_number_cont", with: "R200"
      click_on 'Filter Results'
      within_row(1) do
        expect(page).to have_content("R200")
      end

      # Ensure that the other inspection doesn't show up
      within("table#listing_orders") { expect(page).not_to have_content("R100") }
    end

    it "should return both complete and incomplete inspections when only complete inspections is not checked" do
      Gesmew::Inspection.create! email: "incomplete@example.com", completed_at: nil, state: 'cart'
      click_on 'Filter'
      uncheck "q_completed_at_not_null"
      click_on 'Filter Results'

      expect(page).to have_content("R200")
      expect(page).to have_content("incomplete@example.com")
    end

    it "should be able to filter risky inspections" do
      # Check risky and filter
      check "q_considered_risky_eq"
      click_on 'Filter Results'

      # Insure checkbox still checked
      expect(find("#q_considered_risky_eq")).to be_checked
      # Insure we have the risky inspection, R100
      within_row(1) do
        expect(page).to have_content("R100")
      end
      # Insure the non risky inspection is not present
      expect(page).not_to have_content("R200")
    end

    it "should be able to filter on variant_sku" do
      click_on 'Filter'
      fill_in "q_line_items_variant_sku_eq", with: order1.line_items.first.variant.sku
      click_on 'Filter Results'

      within_row(1) do
        expect(page).to have_content(order1.number)
      end

      expect(page).not_to have_content(order2.number)
    end

    context "when pagination is really short" do
      before do
        @old_per_page = Gesmew::Config[:orders_per_page]
        Gesmew::Config[:orders_per_page] = 1
      end

      after do
        Gesmew::Config[:orders_per_page] = @old_per_page
      end

      # Regression test for #4004
      it "should be able to go from page to page for incomplete inspections" do
        Gesmew::Inspection.destroy_all
        2.times { Gesmew::Inspection.create! email: "incomplete@example.com", completed_at: nil, state: 'cart' }
        click_on 'Filter'
        uncheck "q_completed_at_not_null"
        click_on 'Filter Results'
        within(".pagination") do
          click_link "2"
        end
        expect(page).to have_content("incomplete@example.com")
        expect(find("#q_completed_at_not_null")).not_to be_checked
      end
    end

    it "should be able to search inspections using only completed at input" do
      fill_in "q_created_at_gt", with: Date.current
      click_on 'Filter Results'

      within_row(1) { expect(page).to have_content("R100") }

      # Ensure that the other inspection doesn't show up
      within("table#listing_orders") { expect(page).not_to have_content("R200") }
    end

    context "filter on promotions" do
      let!(:promotion) { create(:promotion_with_item_adjustment) }

      before do
        order1.promotions << promotion
        order1.save
        visit gesmew.admin_orders_path
      end

      it "only shows the inspections with the selected promotion" do
        select promotion.name, from: "Promotion"
        click_on 'Filter Results'
        within_row(1) { expect(page).to have_content("R100") }
        within("table#listing_orders") { expect(page).not_to have_content("R200") }
      end
    end

    it "should be able to apply a ransack filter by clicking a quickfilter icon", js: true do
      label_pending = page.find '.label-pending'
      parent_td = label_pending.find(:xpath, '..')

      # Click the quick filter Pending for inspection #R100
      within(parent_td) do
        find('.js-add-filter').click
      end

      expect(page).to have_content("R100")
      expect(page).not_to have_content("R200")
    end

    context "filter on shipment state" do
      it "only shows the inspections with the selected shipment state" do
        select Gesmew.t("payment_states.#{order1.shipment_state}"), from: "Shipment State"
        click_on 'Filter Results'
        within_row(1) { expect(page).to have_content("R100") }
        within("table#listing_orders") { expect(page).not_to have_content("R200") }
      end
    end

    context "filter on payment state" do
      it "only shows the inspections with the selected payment state" do
        select Gesmew.t("payment_states.#{order1.payment_state}"), from: "Payment State"
        click_on 'Filter Results'
        within_row(1) { expect(page).to have_content("R100") }
        within("table#listing_orders") { expect(page).not_to have_content("R200") }
      end
    end
  end
end
