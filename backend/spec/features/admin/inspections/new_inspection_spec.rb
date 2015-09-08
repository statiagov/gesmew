require 'spec_helper'

describe "New Inspection", :type => :feature, js:true do
  let!(:establishment) { create(:establishment) }
  let!(:inspection_type) { create(:inspection_type) }
  let!(:user) { create(:admin_user,email: 'user@example.com', firstname:'Gerwin', lastname:'Schoobe') }

  stub_authorization!

  before do
    visit gesmew.new_admin_inspection_path
  end

  it "does check if you have a establishment and inspector before letting proccess the inspection" do
    sleep 10.minute
  end

  it "completes new inspection successfully without using the cart", js: true do
    select2_search establishment.name, from: Gesmew.t(:name_or_sku)
    click_icon :add
    wait_for_ajax
    click_on "Customer"

    within "#select-customer" do
      targetted_select2_search user.email, from: "#s2id_customer_search"
    end

    check "order_use_billing"
    fill_in_address
    click_on "Update"

    click_on "Payments"
    click_on "Update"

    expect(current_path).to eql(gesmew.admin_order_payments_path(Gesmew::Inspection.last))
    click_icon "capture"

    click_on "Shipments"
    click_on "Ship"
    wait_for_ajax

    expect(page).to have_content("shipped")
  end

  context "adding new item to the inspection", js: true do
    it "inventory items show up just fine and are also registered as shipments" do
      select2_search establishment.name, from: Gesmew.t(:name_or_sku)

      within("table.stock-levels") do
        fill_in "variant_quantity", with: 2
        click_icon :add
      end

      within(".line-items") do
        expect(page).to have_content(establishment.name)
      end

      click_on "Customer"

      within "#select-customer" do
        targetted_select2_search user.email, from: "#s2id_customer_search"
      end

      check "order_use_billing"
      fill_in_address
      click_on "Update"

      click_on "Shipments"

      within(".stock-contents") do
        expect(page).to have_content(establishment.name)
      end
    end
  end

  # Regression test for #3958
  context "without a delivery step", js: true do
    before do
      allow(Gesmew::Inspection).to receive_messages checkout_step_names: [:address, :payment, :confirm, :complete]
    end

    it "can still see line items" do
      select2_search establishment.name, from: Gesmew.t(:name_or_sku)
      click_icon :add
      within(".line-items") do
        within(".line-item-name") do
          expect(page).to have_content(establishment.name)
        end
        within(".line-item-qty-show") do
          expect(page).to have_content("1")
        end
        within(".line-item-price") do
          expect(page).to have_content(establishment.price)
        end
      end
    end
  end

  # Regression test for #3336
  context "start by customer address" do
    it "completes inspection fine", js: true do
      click_on "Customer"

      within "#select-customer" do
        targetted_select2_search user.email, from: "#s2id_customer_search"
      end

      check "order_use_billing"
      fill_in_address
      click_on "Update"

      click_on "Shipments"
      select2_search establishment.name, from: Gesmew.t(:name_or_sku)
      click_icon :add
      wait_for_ajax

      click_on "Payments"
      click_on "Continue"

      within(".additional-info .state") do
        expect(page).to have_content("complete")
      end
    end
  end

  # Regression test for #5327
  context "customer with default credit card", js: true do
    before do
      create(:credit_card, default: true, user: user)
    end
    it "transitions to delivery not to complete" do
      select2_search establishment.name, from: Gesmew.t(:name_or_sku)
      within("table.stock-levels") do
        fill_in "variant_quantity", with: 1
        click_icon :add
      end
      wait_for_ajax
      click_link "Customer"
      targetted_select2 user.email, from: "#s2id_customer_search"
      click_button "Update"
      expect(Gesmew::Inspection.last.state).to eq 'delivery'
    end
  end

  def fill_in_address(kind = "bill")
    fill_in "First Name",                with: "John 99"
    fill_in "Last Name",                 with: "Doe"
    fill_in "Street Address",            with: "100 first lane"
    fill_in "Street Address (cont'd)",   with: "#101"
    fill_in "City",                      with: "Bethesda"
    fill_in "Zip",                       with: "20170"
    targetted_select2_search state.name, from: "#s2id_order_#{kind}_address_attributes_state_id"
    fill_in "Phone",                     with: "123-456-7890"
  end
end
