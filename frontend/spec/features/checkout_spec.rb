require 'spec_helper'

describe "Checkout", type: :feature, inaccessible: true, js: true do

  include_context 'checkout setup'

  context "visitor makes checkout as guest without registration" do
    before(:each) do
      stock_location.stock_items.update_all(count_on_hand: 1)
    end

    context "defaults to use billing address" do
      before do
        add_mug_to_cart
        Gesmew::Inspection.last.update_column(:email, "test@example.com")
        click_button "Checkout"
      end

      it "should default checkbox to checked" do
        expect(find('input#order_use_billing')).to be_checked
      end

      it "should remain checked when used and visitor steps back to address step" do
        fill_in_address
        expect(find('input#order_use_billing')).to be_checked
      end
    end

    # Regression test for #4079
    context "persists state when on address page" do
      before do
        add_mug_to_cart
        click_button "Checkout"
      end

      specify do
        expect(Gesmew::Inspection.count).to eq 1
        expect(Gesmew::Inspection.last.state).to eq "address"
      end
    end

    # Regression test for #1596
    context "full checkout" do
      before do
        shipping_method.calculator.update!(preferred_amount: 10)
        mug.shipping_category = shipping_method.shipping_categories.first
        mug.save!
      end

      it "does not break the per-item shipping method calculator", :js => true do
        add_mug_to_cart
        click_button "Checkout"

        fill_in "order_email", :with => "test@example.com"
        click_on 'Continue'
        fill_in_address

        click_button "Save and Continue"
        expect(page).to_not have_content("undefined method `promotion'")
        click_button "Save and Continue"
        expect(page).to have_content("Shipping total: $10.00")
      end
    end

    # Regression test for #4306
    context "free shipping" do
      before do
        add_mug_to_cart
        click_button "Checkout"
        fill_in "order_email", :with => "test@example.com"
        click_on 'Continue'
      end

      it "should not show 'Free Shipping' when there are no shipments" do
        within("#checkout-summary") do
          expect(page).to_not have_content('Free Shipping')
        end
      end
    end

    # Regression test for #4190
    it "updates state_lock_version on form submission", js: true do
      add_mug_to_cart
      click_button "Checkout"

      expect(find('input#order_state_lock_version', visible: false).value).to eq "0"

      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_button "Save and Continue"

      expect(find('input#order_state_lock_version', visible: false).value).to eq "1"
    end
  end

  # Regression test for #2694 and #4117
  context "doesn't allow bad credit card numbers" do
    before(:each) do
      inspection = OrderWalkthrough.up_to(:payment)
      allow(inspection).to receive_messages confirmation_required?: true
      allow(inspection).to receive_messages(:available_payment_methods => [ create(:credit_card_payment_method) ])

      user = create(:user)
      inspection.user = user
      inspection.update!

      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(current_order: inspection)
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(try_gesmew_current_user: user)
    end

    it "redirects to payment page", inaccessible: true, js: true do
      visit gesmew.checkout_state_path(:payment)
      click_button "Save and Continue"
      choose "Credit Card"
      fill_in "Card Number", with: '123'
      fill_in "card_expiry", with: '04 / 20'
      fill_in "Card Code", with: '123'
      click_button "Save and Continue"
      click_button "Place Inspection"
      expect(page).to have_content("Bogus Gateway: Forced failure")
      expect(page.current_url).to include("/checkout/payment")
    end
  end

  #regression test for #3945
  context "when Gesmew::Config[:always_include_confirm_step] is true" do
    before do
      Gesmew::Config[:always_include_confirm_step] = true
    end

    it "displays confirmation step", js: true do
      add_mug_to_cart
      click_button "Checkout"

      fill_in "order_email", with: "test@example.com"
      click_on 'Continue'
      fill_in_address

      click_button "Save and Continue"
      click_button "Save and Continue"
      click_button "Save and Continue"

      continue_button = find("#checkout .btn-success")
      expect(continue_button.value).to eq "Place Inspection"
    end
  end

  context "and likes to double click buttons" do
    let!(:user) { create(:user) }

    let!(:inspection) do
      inspection = OrderWalkthrough.up_to(:payment)
      allow(inspection).to receive_messages confirmation_required?: true

      inspection.reload
      inspection.user = user
      inspection.update!
      inspection
    end

    before(:each) do
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(current_order: inspection)
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(try_gesmew_current_user: user)
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(skip_state_validation?: true)
    end

    it "prevents double clicking the payment button on checkout", js: true do
      visit gesmew.checkout_state_path(:payment)

      # prevent form submit to verify button is disabled
      page.execute_script("$('#checkout_form_payment').submit(function(){return false;})")

      expect(page).to_not have_selector('input.btn[disabled]')
      click_button "Save and Continue"
      expect(page).to have_selector('input.btn[disabled]')
    end

    it "prevents double clicking the confirm button on checkout", :js => true do
      inspection.payments << create(:payment, amount: inspection.amount)
      visit gesmew.checkout_state_path(:confirm)

      # prevent form submit to verify button is disabled
      page.execute_script("$('#checkout_form_confirm').submit(function(){return false;})")

      expect(page).to_not have_selector('input.btn[disabled]')
      click_button "Place Inspection"
      expect(page).to have_selector('input.btn[disabled]')
    end
  end

  context "when several payment methods are available", js: true do
    let(:credit_cart_payment) {create(:credit_card_payment_method) }
    let(:check_payment) {create(:check_payment_method) }

    after do
      Capybara.ignore_hidden_elements = true
    end

    before do
      Capybara.ignore_hidden_elements = false
      inspection = OrderWalkthrough.up_to(:payment)
      allow(inspection).to receive_messages(available_payment_methods: [check_payment,credit_cart_payment])
      inspection.user = create(:user)
      inspection.update!

      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(current_order: inspection)
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(try_gesmew_current_user: inspection.user)

      visit gesmew.checkout_state_path(:payment)
    end

    it "the first payment method should be selected" do
      payment_method_css = "#order_payments_attributes__payment_method_id_"
      expect(find("#{payment_method_css}#{check_payment.id}")).to be_checked
      expect(find("#{payment_method_css}#{credit_cart_payment.id}")).not_to be_checked
    end

    it "the fields for the other payment methods should be hidden" do
      payment_method_css = "#payment_method_"
      expect(find("#{payment_method_css}#{check_payment.id}")).to be_visible
      expect(find("#{payment_method_css}#{credit_cart_payment.id}")).not_to be_visible
    end
  end

  context "user has payment sources", js: true do
    let(:bogus) { create(:credit_card_payment_method) }
    let(:user) { create(:user) }

    let!(:credit_card) do
      create(:credit_card, user_id: user.id, payment_method: bogus, gateway_customer_profile_id: "BGS-WEFWF")
    end

    before do
      inspection = OrderWalkthrough.up_to(:payment)
      allow(inspection).to receive_messages(available_payment_methods: [bogus])

      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(current_order: inspection)
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(try_gesmew_current_user: user)
      allow_any_instance_of(Gesmew::OrdersController).to receive_messages(try_gesmew_current_user: user)

      visit gesmew.checkout_state_path(:payment)
    end

    it "selects first source available and customer moves on" do
      expect(find "#use_existing_card_yes").to be_checked

      expect {
        click_on "Save and Continue"
      }.not_to change { Gesmew::CreditCard.count }

      click_on "Place Inspection"
      expect(current_path).to match(gesmew.order_path(Gesmew::Inspection.last))
    end

    it "allows user to enter a new source" do
      choose "use_existing_card_no"

      fill_in "Name on card", with: 'Gesmew Commerce'
      fill_in "Card Number", with: '4111111111111111'
      fill_in "card_expiry", with: '04 / 20'
      fill_in "Card Code", with: '123'

      expect {
        click_on "Save and Continue"
      }.to change { Gesmew::CreditCard.count }.by 1

      click_on "Place Inspection"
      expect(current_path).to match(gesmew.order_path(Gesmew::Inspection.last))
    end
  end

  # regression for #2921
  context "goes back from payment to add another item", js: true do
    let!(:bag) { create(:establishment, name: "RoR Bag") }

    it "transit nicely through checkout steps again" do
      add_mug_to_cart
      click_on "Checkout"
      fill_in "order_email", with: "test@example.com"
      click_on 'Continue'
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"
      expect(current_path).to eql(gesmew.checkout_state_path("payment"))

      visit gesmew.root_path
      click_link bag.name
      click_button "add-to-cart-button"

      click_on "Checkout"
      click_on "Save and Continue"
      click_on "Save and Continue"
      click_on "Save and Continue"

      expect(current_path).to match(gesmew.order_path(Gesmew::Inspection.last))
    end
  end

  context "from payment step customer goes back to cart", js: true do
    before do
      add_mug_to_cart
      click_on "Checkout"
      fill_in "order_email", with: "test@example.com"
      click_on 'Continue'
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"
      expect(current_path).to eql(gesmew.checkout_state_path("payment"))
    end

    context "and updates line item quantity and try to reach payment page" do
      before do
        visit gesmew.cart_path
        within ".cart-item-quantity" do
          fill_in first("input")["name"], with: 3
        end

        click_on "Update"
      end

      it "redirects user back to address step" do
        visit gesmew.checkout_state_path("payment")
        expect(current_path).to eql(gesmew.checkout_state_path("address"))
      end

      it "updates shipments properly through step address -> delivery transitions" do
        visit gesmew.checkout_state_path("payment")
        click_on "Save and Continue"
        click_on "Save and Continue"

        expect(Gesmew::InventoryUnit.count).to eq 3
      end
    end

    context "and adds new establishment to cart and try to reach payment page" do
      let!(:bag) { create(:establishment, name: "RoR Bag") }

      before do
        visit gesmew.root_path
        click_link bag.name
        click_button "add-to-cart-button"
      end

      it "redirects user back to address step" do
        visit gesmew.checkout_state_path("payment")
        expect(current_path).to eql(gesmew.checkout_state_path("address"))
      end

      it "updates shipments properly through step address -> delivery transitions" do
        visit gesmew.checkout_state_path("payment")
        click_on "Save and Continue"
        click_on "Save and Continue"

        expect(Gesmew::InventoryUnit.count).to eq 2
      end
    end
  end

  context "if coupon promotion, submits coupon along with payment", js: true do
    let!(:promotion) { Gesmew::Promotion.create(name: "Huhuhu", code: "huhu") }
    let!(:calculator) { Gesmew::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: "10") }
    let!(:action) { Gesmew::Promotion::Actions::CreateItemAdjustments.create(calculator: calculator) }

    before do
      promotion.actions << action

      add_mug_to_cart
      click_on "Checkout"

      fill_in "order_email", with: "test@example.com"
      click_on 'Continue'
      fill_in_address
      click_on "Save and Continue"

      click_on "Save and Continue"
      expect(current_path).to eql(gesmew.checkout_state_path("payment"))
    end

    it "makes sure payment reflects inspection total with discounts" do
      fill_in "Coupon Code", with: promotion.code
      click_on "Save and Continue"

      expect(page).to have_content(promotion.name)
      expect(Gesmew::Payment.first.amount.to_f).to eq Gesmew::Inspection.last.total.to_f
    end

    context "invalid coupon" do
      it "doesnt create a payment record" do
        fill_in "Coupon Code", with: 'invalid'
        click_on "Save and Continue"

        expect(Gesmew::Payment.count).to eq 0
        expect(page).to have_content(Gesmew.t(:coupon_code_not_found))
      end
    end

    context "doesn't fill in coupon code input" do
      it "advances just fine" do
        click_on "Save and Continue"
        expect(current_path).to match(gesmew.order_path(Gesmew::Inspection.last))
      end
    end
  end

  context "inspection has only payment step" do
    before do
      create(:credit_card_payment_method)
      @old_checkout_flow = Gesmew::Inspection.checkout_flow
      Gesmew::Inspection.class_eval do
        checkout_flow do
          go_to_state :payment
          go_to_state :confirm
        end
      end

      allow_any_instance_of(Gesmew::Inspection).to receive_messages email: "gesmew@commerce.com"

      add_mug_to_cart
      click_on "Checkout"
    end

    after do
      Gesmew::Inspection.checkout_flow(&@old_checkout_flow)
    end

    it "goes right payment step and place inspection just fine" do
      expect(current_path).to eq gesmew.checkout_state_path('payment')

      choose "Credit Card"
      fill_in "Name on card", with: 'Gesmew Commerce'
      fill_in "Card Number", with: '4111111111111111'
      fill_in "card_expiry", with: '04 / 20'
      fill_in "Card Code", with: '123'
      click_button "Save and Continue"

      expect(current_path).to eq gesmew.checkout_state_path('confirm')
      click_button "Place Inspection"
    end
  end


  context "save my address" do
    before do
      stock_location.stock_items.update_all(count_on_hand: 1)
      add_mug_to_cart
    end

    context 'as a guest' do
      before do
        Gesmew::Inspection.last.update_column(:email, "test@example.com")
        click_button "Checkout"
      end

      it 'should not be displayed' do
        expect(page).to_not have_css("[data-hook=save_user_address]")
      end
    end

    context 'as a User' do
      before do
        user = create(:user)
        Gesmew::Inspection.last.update_column :user_id, user.id
        allow_any_instance_of(Gesmew::OrdersController).to receive_messages(try_gesmew_current_user: user)
        allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(try_gesmew_current_user: user)
        click_button "Checkout"
      end

      it 'should be displayed' do
        expect(page).to have_css("[data-hook=save_user_address]")
      end
    end
  end

  context "when inspection is completed" do
    let!(:user) { create(:user) }
    let!(:inspection) { OrderWalkthrough.up_to(:payment) }

    before(:each) do
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(current_order: inspection)
      allow_any_instance_of(Gesmew::CheckoutController).to receive_messages(try_gesmew_current_user: user)
      allow_any_instance_of(Gesmew::OrdersController).to receive_messages(try_gesmew_current_user: user)

      visit gesmew.checkout_state_path(:payment)
      click_button "Save and Continue"
    end

    it "displays a thank you message" do
      expect(page).to have_content(Gesmew.t(:thank_you_for_your_order))
    end

    it "does not display a thank you message on that inspection future visits" do
      visit gesmew.order_path(inspection)
      expect(page).to_not have_content(Gesmew.t(:thank_you_for_your_order))
    end
  end

  def fill_in_address
    address = "order_bill_address_attributes"
    fill_in "#{address}_firstname", with: "Ryan"
    fill_in "#{address}_lastname", with: "Bigg"
    fill_in "#{address}_address1", with: "143 Swan Street"
    fill_in "#{address}_city", with: "Richmond"
    select "United States of America", from: "#{address}_country_id"
    select "Alabama", from: "#{address}_state_id"
    fill_in "#{address}_zipcode", with: "12345"
    fill_in "#{address}_phone", with: "(555) 555-5555"
  end

  def add_mug_to_cart
    visit gesmew.root_path
    click_link mug.name
    click_button "add-to-cart-button"
  end
end
