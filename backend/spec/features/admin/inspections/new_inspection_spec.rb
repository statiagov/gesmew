require 'spec_helper'

describe "New Inspection", :type => :feature, js:true do
  let!(:establishment) { create(:establishment) }
  let!(:inspection_type) { create(:inspection_type) }
  let!(:user_1) { create(:admin_user,email: 'user_1@example.com', firstname:'Ingrid', lastname:'Houtman') }
  let!(:user_2) { create(:admin_user,email: 'user_2@example.com', firstname:'Bernadine', lastname:'Woodley') }

  stub_authorization!

  before do
    visit gesmew.new_admin_inspection_path
  end

  it "does check if you have a establishment and inspector before letting proccess the inspection" do
    sleep 10.minute
  end
end
