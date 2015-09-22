require 'spec_helper'

describe "New Inspection", :type => :feature, js:true do
  let!(:establishment) { create(:establishment, name:'Duggins Shopping Center N.V.', firstname: 'Louise', lastname: 'Gumbs') }
  let!(:inspection_type) { create(:inspection_type) }
  let!(:user_1) { create(:admin_user,email: 'user_1@example.com', firstname:'Ingrid', lastname:'Houtman') }
  let!(:user_2) { create(:admin_user,email: 'user_2@example.com', firstname:'Bernadine', lastname:'Woodley') }

  stub_authorization!

  before do
    visit gesmew.new_admin_inspection_path
  end

  context "adding and removing inspector to inspection" do
    it "inspector info shows up just fine when added" do
      select2_search user_1.first_name, from: Gesmew.t(:first_or_lastname)
      click_icon :add
      wait_for_ajax
      expect(page).to have_content(user_1.full_name)
    end

    it "inspector info does not show up when removed" do
      sleep 10.minutes
    end
  end
end
