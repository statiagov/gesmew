# encoding: utf-8
require 'spec_helper'

describe "Products", type: :feature do
  context "as admin user" do
    stub_authorization!

    def build_option_type_with_values(name, values)
      ot = FactoryGirl.create(:option_type, name: name)
      values.each do |val|
        ot.option_values.create(name: val.downcase, presentation: val)
      end
      ot
    end

    context "listing establishments" do
      context "sorting" do
        before do
          create(:establishment, name: 'apache baseball cap', price: 10)
          create(:establishment, name: 'zomg shirt', price: 5)
        end

        it "should list existing establishments with correct sorting by name" do
          visit gesmew.admin_products_path
          # Name ASC
          within_row(1) { expect(page).to have_content('apache baseball cap') }
          within_row(2) { expect(page).to have_content("zomg shirt") }

          # Name DESC
          click_link "admin_products_listing_name_title"
          within_row(1) { expect(page).to have_content("zomg shirt")  }
          within_row(2) { expect(page).to have_content('apache baseball cap') }
        end

        it "should list existing establishments with correct sorting by price" do
          visit gesmew.admin_products_path
          # Name ASC (default)
          within_row(1) { expect(page).to have_content('apache baseball cap') }
          within_row(2) { expect(page).to have_content("zomg shirt") }

          # Price DESC
          click_link "admin_products_listing_price_title"
          within_row(1) { expect(page).to have_content("zomg shirt") }
          within_row(2) { expect(page).to have_content('apache baseball cap') }
        end
      end

      context "currency displaying" do
        context "using Russian Rubles" do
          before do
            Gesmew::Config[:currency] = "RUB"
          end

          let!(:establishment) do
            create(:establishment, name: "Just a establishment", price: 19.99)
          end

          # Regression test for #2737
          context "uses руб as the currency symbol" do
            it "on the establishments listing page" do
              visit gesmew.admin_products_path
              within_row(1) { expect(page).to have_content("19.99 ₽") }
            end
          end
        end
      end
    end

    context "searching establishments" do
      it "should be able to search deleted establishments" do
        create(:establishment, name: 'apache baseball cap', deleted_at: "2011-01-06 18:21:13")
        create(:establishment, name: 'zomg shirt')

        visit gesmew.admin_products_path
        expect(page).to have_content("zomg shirt")
        expect(page).not_to have_content("apache baseball cap")

        check "Show Deleted"
        click_on 'Search'

        expect(page).to have_content("zomg shirt")
        expect(page).to have_content("apache baseball cap")

        uncheck "Show Deleted"
        click_on 'Search'

        expect(page).to have_content("zomg shirt")
        expect(page).not_to have_content("apache baseball cap")
      end

      it "should be able to search establishments by their properties" do
        create(:establishment, name: 'apache baseball cap', sku: "A100")
        create(:establishment, name: 'apache baseball cap2', sku: "B100")
        create(:establishment, name: 'zomg shirt')

        visit gesmew.admin_products_path
        fill_in "q_name_cont", with: "ap"
        click_on 'Search'

        expect(page).to have_content("apache baseball cap")
        expect(page).to have_content("apache baseball cap2")
        expect(page).not_to have_content("zomg shirt")

        fill_in "q_variants_including_master_sku_cont", with: "A1"
        click_on 'Search'

        expect(page).to have_content("apache baseball cap")
        expect(page).not_to have_content("apache baseball cap2")
        expect(page).not_to have_content("zomg shirt")
      end
    end

    context "creating a new establishment from a prototype", js: true do
      def build_option_type_with_values(name, values)
        ot = FactoryGirl.create(:option_type, name: name)
        values.each do |val|
          ot.option_values.create(name: val.downcase, presentation: val)
        end
        ot
      end

      let(:product_attributes) do
        # FactoryGirl.attributes_for is un-deprecated!
        #   https://github.com/thoughtbot/factory_girl/issues/274#issuecomment-3592054
        FactoryGirl.attributes_for(:simple_product)
      end

      let(:prototype) do
        size = build_option_type_with_values("size", %w(Small Medium Large))
        FactoryGirl.create(:prototype, name: "Size", option_types: [ size ])
      end

      let(:option_values_hash) do
        hash = {}
        prototype.option_types.each do |i|
          hash[i.id.to_s] = i.option_value_ids
        end
        hash
      end

      before(:each) do
        @option_type_prototype = prototype
        @property_prototype = create(:prototype, name: "Random")
        @shipping_category = create(:shipping_category)
        visit gesmew.admin_products_path
        click_link "admin_new_product"
        within('#new_product') do
          expect(page).to have_content("SKU")
        end
      end

      it "should allow an admin to create a new establishment and variants from a prototype" do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        fill_in "product_available_on", with: "2012/01/24"
        # Just so the datepicker gets out of poltergeists way.
        page.execute_script("$('#ui-datepicker-div').hide();")
        select "Size", from: "Prototype"
        wait_for_ajax
        check "Large"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        expect(page).to have_content("successfully created!")
        expect(Gesmew::Establishment.last.variants.length).to eq(1)
      end

      it "should not display variants when prototype does not contain option types" do
        select "Random", from: "Prototype"

        fill_in "product_name", with: "Baseball Cap"

        expect(page).not_to have_content("Variants")
      end

      it "should keep option values selected if validation fails" do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        select "Size", from: "Prototype"
        wait_for_ajax
        check "Large"
        click_button "Create"
        expect(page).to have_content("Shipping category can't be blank")
        expect(field_labeled("Size")).to be_checked
        expect(field_labeled("Large")).to be_checked
        expect(field_labeled("Small")).not_to be_checked
      end
    end

    context "creating a new establishment" do
      before(:each) do
        @shipping_category = create(:shipping_category)
        visit gesmew.admin_products_path
        click_link "admin_new_product"
        within('#new_product') do
          expect(page).to have_content("SKU")
        end
      end

      it "should allow an admin to create a new establishment" do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        fill_in "product_available_on", with: "2012/01/24"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        expect(page).to have_content("successfully created!")
        click_button "Update"
        expect(page).to have_content("successfully updated!")
      end

      it "should show validation errors" do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        click_button "Create"
        expect(page).to have_content("Shipping category can't be blank")
      end

      context "using a locale with a different decimal format " do
        before do
          # change English locale’s separator and delimiter to match 19,99 format
          I18n.backend.store_translations(:en,
            :number => {
              :currency => {
                :format => {
                  :separator => ",",
                  :delimiter => "."
                }
              }
            })
        end

        after do
          # revert changes to English locale
          I18n.backend.store_translations(:en,
            :number => {
              :currency => {
                :format => {
                  :separator => ".",
                  :delimiter => ","
                }
              }
            })
        end

        it "should show localized price value on validation errors", :js => true do
          fill_in "product_price", :with => "19,99"
          click_button "Create"
          expect(find('input#product_price').value).to eq('19,99')
        end
      end

      # Regression test for #2097
      it "can set the count on hand to a null value" do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_price", with: "100"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        expect(page).to have_content("successfully created!")
        click_button "Update"
        expect(page).to have_content("successfully updated!")
      end
    end


    context "cloning a establishment", js: true do
      it "should allow an admin to clone a establishment" do
        create(:establishment)

        visit gesmew.admin_products_path
        within_row(1) do
          click_icon :clone
        end

        expect(page).to have_content("Establishment has been cloned")
      end

      context "cloning a deleted establishment" do
        it "should allow an admin to clone a deleted establishment" do
          create(:establishment, name: "apache baseball cap")

          visit gesmew.admin_products_path
          click_on 'Filter'
          check "Show Deleted"
          click_on 'Search'

          expect(page).to have_content("apache baseball cap")

          within_row(1) do
            click_icon :clone
          end

          expect(page).to have_content("Establishment has been cloned")
        end
      end
    end

    context 'updating a establishment' do
      let(:establishment) { create(:establishment) }

      let(:prototype) do
        size = build_option_type_with_values("size", %w(Small Medium Large))
        FactoryGirl.create(:prototype, name: "Size", option_types: [ size ])
      end

      before(:each) do
        @option_type_prototype = prototype
        @property_prototype = create(:prototype, name: "Random")
      end

      it 'should parse correctly available_on' do
        visit gesmew.admin_product_path(establishment)
        fill_in "product_available_on", with: "2012/12/25"
        click_button "Update"
        expect(page).to have_content("successfully updated!")
        expect(Gesmew::Establishment.last.available_on.to_s).to eq("2012-12-25 00:00:00 UTC")
      end

      it 'should add option_types when selecting a prototype', js: true do
        visit gesmew.admin_product_path(establishment)
        click_link 'Properties'
        click_link "Select From Prototype"

        within("#prototypes tr#row_#{prototype.id}") do
          click_link 'Select'
          wait_for_ajax
        end

        within(:css, "tr.product_property:first-child") do
          expect(first('input[type=text]').value).to eq('baseball_cap_color')
        end
      end
    end

    context 'deleting a establishment', :js => true do
      let!(:establishment) { create(:establishment) }

      it "is still viewable" do
        visit gesmew.admin_products_path
        accept_alert do
          click_icon :delete
          wait_for_ajax
        end
        click_on 'Filter'
        # This will show our deleted establishment
        check "Show Deleted"
        click_on 'Search'
        click_link establishment.name
        expect(find("#product_price").value.to_f).to eq(establishment.price.to_f)
      end
    end
  end

  context 'with only establishment permissions' do

    before do
      allow_any_instance_of(Gesmew::Admin::BaseController).to receive(:gesmew_current_user).and_return(nil)
    end

    custom_authorization! do |user|
      can [:admin, :update, :index, :read], Gesmew::Establishment
    end
    let!(:establishment) { create(:establishment) }

    it "should only display accessible links on index" do
      visit gesmew.admin_products_path

      expect(page).to have_link('Products')
      expect(page).not_to have_link('Option Types')
      expect(page).not_to have_link('Properties')
      expect(page).not_to have_link('Prototypes')
      expect(page).not_to have_link('New Establishment')
      expect(page).not_to have_css('.icon-clone')
      expect(page).to have_css('.icon-edit')
      expect(page).not_to have_css('.delete-resource')
    end

    it "should only display accessible links on edit" do
      visit gesmew.admin_product_path(establishment)

      # establishment tabs should be hidden
      expect(page).to have_link('Details')
      expect(page).not_to have_link('Images')
      expect(page).not_to have_link('Variants')
      expect(page).not_to have_link('Properties')
      expect(page).not_to have_link('Stock Management')

      # no create permission
      expect(page).not_to have_link('New Establishment')
    end
  end
end
