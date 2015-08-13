require 'spec_helper'

describe "Homepage", :type => :feature, js:true do

  context 'as admin user' do
    stub_authorization!

    context "visiting the homepage" do
      before(:each) do
        visit gesmew.admin_path
      end

      it "should have the header text 'Inspections'" do
        within('h1') { expect(page).to have_content("Inspections") }
      end

      # it "should have a link to overview" do
      #   within("header") { page.find(:xpath, "//a[@href='/admin']") }
      # end
      #
      # it "should have a link to inspections" do
      #   page.find_link("Inspections")['/admin/inspections']
      # end
      #
      # it "should have a link to establishments" do
      #   page.find_link("Establishments")['/admin/establishments']
      # end
      #
      # it "should have a link to reports" do
      #   page.find_link("Reports")['/admin/reports']
      # end
      #
      # it "should have a link to configuration" do
      #   page.find_link("Configuration")['/admin/configurations']
      # end
    end

    # context "visiting the establishments tab" do
    #   before(:each) do
    #     visit gesmew.admin_products_path
    #   end
    #
    #   it "should have a link to establishments" do
    #     within('.sidebar') { page.find_link("Products")['/admin/establishments'] }
    #   end
    #
    #   it "should have a link to option types" do
    #     within('.sidebar') { page.find_link("Option Types")['/admin/option_types'] }
    #   end
    #
    #   it "should have a link to properties" do
    #     within('.sidebar') { page.find_link("Properties")['/admin/properties'] }
    #   end
    #
    #   it "should have a link to prototypes" do
    #     within('.sidebar') { page.find_link("Prototypes")['/admin/prototypes'] }
    #   end
    # end
  end

  # context 'as fakedispatch user' do
  #
  #   before do
  #     allow_any_instance_of(Gesmew::Admin::BaseController).to receive(:gesmew_current_user).and_return(nil)
  #   end
  #
  #   custom_authorization! do |user|
  #     can [:admin, :edit, :index, :read], Gesmew::Inspection
  #   end
  #
  #   it 'should only display tabs fakedispatch has access to' do
  #     visit gesmew.admin_path
  #     expect(page).to have_link('Orders')
  #     expect(page).not_to have_link('Products')
  #     expect(page).not_to have_link('Promotions')
  #     expect(page).not_to have_link('Reports')
  #     expect(page).not_to have_link('Configurations')
  #   end
  # end

end
