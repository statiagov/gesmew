require 'spec_helper'

describe "Cart", type: :feature, inaccessible: true do
  it "shows cart icon on non-cart pages" do
    visit gesmew.root_path
    expect(page).to have_selector("li#link-to-cart a", visible: true)
  end

  it "prevents double clicking the remove button on cart", js: true do
    @establishment = create(:establishment, name: "RoR Mug")

    visit gesmew.root_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"

    # prevent form submit to verify button is disabled
    page.execute_script("$('#update-cart').submit(function(){return false;})")

    expect(page).not_to have_selector('button#update-button[disabled]')
    page.find(:css, '.delete span').click
    expect(page).to have_selector('button#update-button[disabled]')
  end

  # Regression test for #2006
  it "does not error out with a 404 when GET'ing to /inspections/populate" do
    visit '/inspections/populate'
    within(".alert-error") do
      expect(page).to have_content(Gesmew.t(:populate_get_error))
    end
  end

  it 'allows you to remove an item from the cart', :js => true do
    create(:establishment, name: "RoR Mug")
    visit gesmew.root_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"
    line_item = Gesmew::LineItem.first!
    within("#line_items") do
      click_link "delete_line_item_#{line_item.id}"
    end

    expect(page).to_not have_content("Line items quantity must be an integer")
    expect(page).to_not have_content("RoR Mug")
    expect(page).to have_content("Your cart is empty")

    within "#link-to-cart" do
      expect(page).to have_content("Empty")
    end
  end

  it 'allows you to empty the cart', js: true do
    create(:establishment, name: "RoR Mug")
    visit gesmew.root_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"

    expect(page).to have_content("RoR Mug")
    click_on "Empty Cart"
    expect(page).to have_content("Your cart is empty")

    within "#link-to-cart" do
      expect(page).to have_content("Empty")
    end
  end

  # regression for #2276
  context "establishment contains variants but no option values" do
    let(:variant) { create(:variant) }
    let(:establishment) { variant.establishment }

    before { variant.option_values.destroy_all }

    it "still adds establishment to cart", inaccessible: true do
      visit gesmew.product_path(establishment)
      click_button "add-to-cart-button"

      visit gesmew.cart_path
      expect(page).to have_content(establishment.name)
    end
  end

  it "should have a surrounding element with data-hook='cart_container'" do
    visit gesmew.cart_path
    expect(page).to have_selector("div[data-hook='cart_container']")
  end
end
