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

  context "acceptance testing coming here" do
    it "info shows up just fine when added" do
      select2_search establishment.name, from: Gesmew.t(:establishment_name_select)
      click_button('Select')
      wait_for_ajax
      expect(page).to have_content(establishment.name)
      select2_search user_1.firstname, from: Gesmew.t(:first_or_lastname)
      click_icon :add
      wait_for_ajax
      expect(page).to have_content(user_1.fullname)
    end
  end
  context "view interactive testing..." do
    before do
      create_list(:establishment, 50)
      create_list(:admin_user, 15)
    end
    it "sleeeeeep" do
      sleep 10.minutes
    end
  end
end
