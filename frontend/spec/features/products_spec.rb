# encoding: utf-8
require 'spec_helper'

describe "Visiting Products", type: :feature, inaccessible: true do
  include_context "custom establishments"

  let(:store_name) do
    ((first_store = Gesmew::Store.first) && first_store.name).to_s
  end

  before(:each) do
    visit gesmew.root_path
  end

  it "should be able to show the shopping cart after adding a establishment to it" do
    click_link "Ruby on Rails Ringer T-Shirt"
    expect(page).to have_content("$19.99")

    click_button 'add-to-cart-button'
    expect(page).to have_content("Shopping Cart")
  end

  describe 'meta tags and title' do
    let(:jersey) { Gesmew::Establishment.find_by_name('Ruby on Rails Baseball Jersey') }
    let(:metas) { { meta_description: 'Brand new Ruby on Rails Jersey', meta_title: 'Ruby on Rails Baseball Jersey Buy High Quality Geek Apparel', meta_keywords: 'ror, jersey, ruby' } }

    it 'should return the correct title when displaying a single establishment' do
      click_link jersey.name
      expect(page).to have_title('Ruby on Rails Baseball Jersey - ' + store_name)
      within('div#establishment-description') do
        within('h1.establishment-title') do
          expect(page).to have_content('Ruby on Rails Baseball Jersey')
        end
      end
    end

    it 'displays metas' do
      jersey.update_attributes metas
      click_link jersey.name
      expect(page).to have_meta(:description, 'Brand new Ruby on Rails Jersey')
      expect(page).to have_meta(:keywords, 'ror, jersey, ruby')
    end

    it 'displays title if set' do
      jersey.update_attributes metas
      click_link jersey.name
      expect(page).to have_title('Ruby on Rails Baseball Jersey Buy High Quality Geek Apparel')
    end

    it "doesn't use meta_title as heading on page" do
      jersey.update_attributes metas
      click_link jersey.name
      within("h1") do
        expect(page).to have_content(jersey.name)
        expect(page).not_to have_content(jersey.meta_title)
      end
    end

    it 'uses establishment name in title when meta_title set to empty string' do
      jersey.update_attributes meta_title: ''
      click_link jersey.name
      expect(page).to have_title('Ruby on Rails Baseball Jersey - ' + store_name)
    end
  end

  context "using Russian Rubles as a currency" do
    before do
      Gesmew::Config[:currency] = "RUB"
    end

    let!(:establishment) do
      establishment = Gesmew::Establishment.find_by_name("Ruby on Rails Ringer T-Shirt")
      establishment.price = 19.99
      establishment.tap(&:save)
    end

    # Regression tests for #2737
    context "uses руб as the currency symbol" do
      it "on establishments page" do
        visit gesmew.root_path
        within("#product_#{establishment.id}") do
          within(".price") do
            expect(page).to have_content("19.99 ₽")
          end
        end
      end

      it "on establishment page" do
        visit gesmew.product_path(establishment)
        within(".price") do
          expect(page).to have_content("19.99 ₽")
        end
      end

      it "when adding a establishment to the cart", js: true do
        visit gesmew.product_path(establishment)
        click_button "Add To Cart"
        click_link "Home"
        within(".cart-info") do
          expect(page).to have_content("19.99 ₽")
        end
      end

      it "when on the 'address' state of the cart", js: true do
        visit gesmew.product_path(establishment)
        click_button "Add To Cart"
        click_button "Checkout"
        fill_in "order_email", with: "test@example.com"
        click_button 'Continue'
        within("tr[data-hook=item_total]") do
          expect(page).to have_content("19.99 ₽")
        end
      end
    end
  end

  it "should be able to search for a establishment" do
    fill_in "keywords", with: "shirt"
    click_button "Search"

    expect(page.all('#establishments .establishment-list-item').size).to eq(1)
  end

  context "a establishment with variants" do
    let(:establishment) { Gesmew::Establishment.find_by_name("Ruby on Rails Baseball Jersey") }
    let(:option_value) { create(:option_value) }
    let!(:variant) { establishment.variants.create!(:price => 5.59) }

    before do
      # Need to have two images to trigger the error
      image = File.open(File.expand_path('../../fixtures/thinking-cat.jpg', __FILE__))
      establishment.images.create!(:attachment => image)
      establishment.images.create!(:attachment => image)

      establishment.option_types << option_value.option_type
      variant.option_values << option_value
    end

    it "should be displayed" do
      expect { click_link establishment.name }.to_not raise_error
    end

    it "displays price of first variant listed", js: true do
      click_link establishment.name
      within("#establishment-price") do
        expect(page).to have_content variant.price
        expect(page).not_to have_content Gesmew.t(:out_of_stock)
      end
    end

    it "doesn't display out of stock for master establishment" do
      establishment.master.stock_items.update_all count_on_hand: 0, backorderable: false

      click_link establishment.name
      within("#establishment-price") do
        expect(page).not_to have_content Gesmew.t(:out_of_stock)
      end
    end
  end

  context "a establishment with variants, images only for the variants" do
    let(:establishment) { Gesmew::Establishment.find_by_name("Ruby on Rails Baseball Jersey") }

    before do
      image = File.open(File.expand_path('../../fixtures/thinking-cat.jpg', __FILE__))
      v1 = establishment.variants.create!(price: 9.99)
      v2 = establishment.variants.create!(price: 10.99)
      v1.images.create!(attachment: image)
      v2.images.create!(attachment: image)
    end

    it "should not display no image available" do
      visit gesmew.root_path
      expect(page).to have_xpath("//img[contains(@src,'thinking-cat')]")
    end
  end

  it "should be able to hide establishments without price" do
    expect(page.all('#establishments .establishment-list-item').size).to eq(9)
    Gesmew::Config.show_products_without_price = false
    Gesmew::Config.currency = "CAN"
    visit gesmew.root_path
    expect(page.all('#establishments .establishment-list-item').size).to eq(0)
  end


  it "should be able to display establishments priced under 10 dollars" do
    within(:css, '#taxonomies') { click_link "Ruby on Rails" }
    check "Price_Range_Under_$10.00"
    within(:css, '#sidebar_products_search') { click_button "Search" }
    expect(page).to have_content("No establishments found")
  end

  it "should be able to display establishments priced between 15 and 18 dollars" do
    within(:css, '#taxonomies') { click_link "Ruby on Rails" }
    check "Price_Range_$15.00_-_$18.00"
    within(:css, '#sidebar_products_search') { click_button "Search" }

    expect(page.all('#establishments .establishment-list-item').size).to eq(3)
    tmp = page.all('#establishments .establishment-list-item a').map(&:text).flatten.compact
    tmp.delete("")
    expect(tmp.sort!).to eq(["Ruby on Rails Mug", "Ruby on Rails Stein", "Ruby on Rails Tote"])
  end

  it "should be able to display establishments priced between 15 and 18 dollars across multiple pages" do
    Gesmew::Config.products_per_page = 2
    within(:css, '#taxonomies') { click_link "Ruby on Rails" }
    check "Price_Range_$15.00_-_$18.00"
    within(:css, '#sidebar_products_search') { click_button "Search" }

    expect(page.all('#establishments .establishment-list-item').size).to eq(2)
    establishments = page.all('#establishments .establishment-list-item a[itemprop=name]')
    expect(establishments.count).to eq(2)

    find('.pagination .next a').click
    establishments = page.all('#establishments .establishment-list-item a[itemprop=name]')
    expect(establishments.count).to eq(1)
  end

  it "should be able to display establishments priced 18 dollars and above" do
    within(:css, '#taxonomies') { click_link "Ruby on Rails" }
    check "Price_Range_$18.00_-_$20.00"
    check "Price_Range_$20.00_or_over"
    within(:css, '#sidebar_products_search') { click_button "Search" }

    expect(page.all('#establishments .establishment-list-item').size).to eq(4)
    tmp = page.all('#establishments .establishment-list-item a').map(&:text).flatten.compact
    tmp.delete("")
    expect(tmp.sort!).to eq(["Ruby on Rails Bag",
                         "Ruby on Rails Baseball Jersey",
                         "Ruby on Rails Jr. Spaghetti",
                         "Ruby on Rails Ringer T-Shirt"])
  end

  it "should be able to put a establishment without a description in the cart" do
    establishment = FactoryGirl.create(:base_product, :description => nil, :name => 'Sample', :price => '19.99')
    visit gesmew.product_path(establishment)
    expect(page).to have_content "This establishment has no description"
    click_button 'add-to-cart-button'
    expect(page).to have_content "This establishment has no description"
  end

  it "shouldn't be able to put a establishment without a current price in the cart" do
    establishment = FactoryGirl.create(:base_product, :description => nil, :name => 'Sample', :price => '19.99')
    Gesmew::Config.currency = "CAN"
    Gesmew::Config.show_products_without_price = true
    visit gesmew.product_path(establishment)
    expect(page).to have_content "This establishment is not available in the selected currency."
    expect(page).not_to have_content "add-to-cart-button"
  end

  it "should return the correct title when displaying a single establishment" do
    establishment = Gesmew::Establishment.find_by_name("Ruby on Rails Baseball Jersey")
    click_link establishment.name

    within("div#establishment-description") do
      within("h1.establishment-title") do
        expect(page).to have_content("Ruby on Rails Baseball Jersey")
      end
    end
  end
end
