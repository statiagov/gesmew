require 'spec_helper'

describe "Inspection Listing", type: :feature, js:true do
  include Gesmew::BaseHelper
  stub_authorization!

  let!(:user_a) { create(:admin_user, email: 'a@example.com') }
  let!(:user_b) { create(:admin_user, email: 'b@example.com') }
  let!(:user_c) { create(:admin_user, email: 'c@example.com', firstname:'Vaughn', lastname:'Sams') }

  let(:inspection_1) do
    create :inspection,
      establishment_name: "Duggins Supermarket N.V.",
      created_at: 1.day.ago,
      completed_at: 1.day.ago,
      considered_risky: true,
      number: "I100"
  end

  let(:inspection_4) do
    create(:inspection,
      created_at: 3.day.ago,
      completed_at: 2.day.ago,
      considered_risky: false,
      number: "I900")
  end

  let(:inspection_2) do
    create :inspection,
      establishment_name: "Golden Era Hotel",
      establishment_type_name: "Hotel",
      created_at: 3.day.ago,
      completed_at: 3.day.ago,
      number: "I200"
  end

  let(:inspection_3) do
    create :inspection,
      created_at: 7.day.ago,
      completed_at: 7.day.ago,
      considered_risky: false,
      number: "I600"
  end

  before do
    user_a.inspections << [inspection_1,inspection_2]
    user_b.inspections << [inspection_2, inspection_3, inspection_1]
    user_c.inspections << inspection_4

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
        expect(column_text(2)).to eq "I900"
        expect(find("td:nth-child(3)")).to have_css '.label-considered_safe'
      end

      within_row(3) do
        expect(column_text(2)).to eq "I200"
        expect(find("td:nth-child(3)")).to have_css '.label-undetermined'
      end

      within_row(4) do
        expect(column_text(2)).to eq "I600"
        expect(find("td:nth-child(3)")).to have_css '.label-considered_safe'
      end
    end

    it "should be able to sort the inspections listing" do
      # default is completed_at desc
      within_row(1) { expect(page).to have_content("I100") }
      within_row(2) { expect(page).to have_content("I900") }
      within_row(3) { expect(page).to have_content("I200") }
      within_row(4) { expect(page).to have_content("I600") }

      click_link "Completed At"

      # Completed at desc
      within_row(1) { expect(page).to have_content("I600") }
      within_row(2) { expect(page).to have_content("I200") }
      within_row(3) { expect(page).to have_content("I900") }
      within_row(4) { expect(page).to have_content("I100") }

      within('table#listing_inspections thead') { click_link "Number" }

      # number asc
      within_row(1) { expect(page).to have_content("I100") }
      within_row(2) { expect(page).to have_content("I200") }
      within_row(3) { expect(page).to have_content("I600") }
      within_row(4) { expect(page).to have_content("I900") }
    end
  end

  describe "searching inspections" do
    it "should be able to quick search inspections" do
      fill_in "quick_search", with: "I200"
      find('#quick-search>input').native.send_keys(:enter)
      within_row(1) do
        expect(page).to have_content("I200")
      end

      # Ensure that the other inspection doesn't show up
      within("table#listing_inspections") do
        expect(page).not_to have_content("I100")
        expect(page).not_to have_content("I600")
      end
    end

    it "should return both complete and incomplete inspections when only complete inspections is not checked" do
      user_b.inspections << create(:inspection,
        created_at: DateTime.now,
        completed_at: nil,
        number: "I300")

      click_on 'Filter'
      uncheck "q_completed_at_not_null"
      click_on 'Filter Results'

      expect(page).to have_content("I300")
    end

    it "should be able to filter risky inspections" do
      # Check risky and filter
      click_on 'Filter'
      check "q_considered_risky_eq"
      click_on 'Filter Results'

      # Insure checkbox still checked
      click_on 'Filter'
      expect(find("#q_considered_risky_eq")).to be_checked
      # Insure we have the risky inspection, R100
      within_row(1) do
        expect(page).to have_content("I100")
      end
      # Insure the non risky inspection is not present
      expect(page).not_to have_content("I200")
      expect(page).not_to have_content("I600")
    end

    context "when pagination is really short" do
      before do
        @old_per_page = Gesmew::Config[:inspections_per_page]
        Gesmew::Config[:inspections_per_page] = 2
      end

      after do
        Gesmew::Config[:inspections_per_page] = @old_per_page
      end

      # Regression test for #4004
      it "should be able to go from page to page for incomplete inspections" do
        click_on 'Filter'
        uncheck "q_completed_at_not_null"
        click_on 'Filter Results'
        within(".pagination") do
          click_link "2"
        end
        expect(page).to have_content("I600")
      end
    end

    it "should be able to search inspections using only completed at input" do
      click_on "Filter"
      fill_in "q_created_at_gt", with: 2.days.ago
      click_on 'Filter Results'

      within_row(1) { expect(page).to have_content("I100") }

      # Ensure that the other inspection doesn't show up
      within("table#listing_inspections") do
       expect(page).not_to have_content("I200")
       expect(page).not_to have_content("I600")
     end
    end

    context "filter on establishment type" do
      it "only shows the inspections with the selected establishment type" do
        label = page.find ".label-#{labelize(inspection_1.establishment.establishment_type.name)}"
        parent_td = label.find(:xpath, '..')

        within(parent_td) do
          find('.js-add-filter').click
        end
        within_row(1) do
          expect(page).to have_content("I100")
        end

        within_row(2) do
          expect(page).to have_content("I900")
        end

        within_row(3) do
          expect(page).to have_content("I600")
        end
        within("table#listing_inspections") {expect(page).not_to have_content("I200")}
      end
    end

    context "filter on inspectors" do
      let(:inspector_1) { create(:user, firstname:'Michail',lastname:'Gumbs') }
      let!(:inspector_2) { create(:user, firstname:"N'kili",lastname:'Gumbs') }

      before do
        inspector_1.inspections <<  inspection_2
        visit gesmew.admin_inspections_path
      end

      it "only shows the inspections with the selected inspector" do
        click_on 'Filter'
        select inspector_1.fullname, from: "Inspector(s)"
        click_on 'Filter Results'
        within_row(1) { expect(page).to have_content("I200") }
        within("table#listing_inspections") do
           expect(page).not_to have_content("I100")
           expect(page).not_to have_content("I600")
        end
      end

      it "only shows the inspections with the selected inspectors" do
        inspector_1.inspections <<  inspection_3
        inspector_2.inspections <<  inspection_3

        click_on 'Filter'
        select inspector_1.fullname, from: "Inspector(s)"
        select inspector_2.fullname, from: "Inspector(s)"
        click_on 'Filter Results'
        within_row(1) do
          expect(page).to have_content("I200")
        end

        within_row(2) do
          expect(page).to have_content("I600")
        end
        within("table#listing_inspections") do
           expect(page).not_to have_content("I100")
        end
      end
    end

    it "should be able to apply a ransack filter by clicking a quickfilter icon", js: true do
      label = page.find ".label-#{labelize(inspection_1.establishment.name)}"
      parent_td = label.find(:xpath, '..')

      within(parent_td) do
        find('.js-add-filter').click
      end
      within_row(1) {expect(page).to have_content("I100")}
      within("table#listing_inspections") do
        expect(page).not_to have_content("I200")
        expect(page).not_to have_content("I600")
      end
    end
  end
end
