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

  it "checks if the inspection has an establishment and at least one inspector before going to the next step", js:false do
    click_button('Next Step')
    expect(page).to have_content('Errors')
  end

  it "" do
    select2_search establishment.name, from: Gesmew.t(:establishment_name_select)
    click_button('Select')
    wait_for_ajax
    expect(page).to have_content(establishment.name)
    select2_search user_1.firstname, from: Gesmew.t(:first_or_lastname)
    click_icon :add
    wait_for_ajax
    expect(page).to have_content(user_1.fullname)
  end

  it "manual testing" do
    sleep 10.minutes
  end
end
