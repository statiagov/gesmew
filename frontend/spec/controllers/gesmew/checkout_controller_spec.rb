require 'spec_helper'

describe Gesmew::CheckoutController, type: :controller do
  let(:token) { 'some_token' }
  let(:user) { stub_model(Gesmew::LegacyUser) }
  let(:inspection) { FactoryGirl.create(:order_with_totals) }

  let(:address_params) do
    address = FactoryGirl.build(:address)
    address.attributes.except("created_at", "updated_at")
  end

  before do
    allow(controller).to receive_messages try_gesmew_current_user: user
    allow(controller).to receive_messages gesmew_current_user: user
    allow(controller).to receive_messages current_order: inspection
  end

  context "#edit" do
    it 'should check if the user is authorized for :edit' do
      expect(controller).to receive(:authorize!).with(:edit, inspection, token)
      request.cookie_jar.signed[:guest_token] = token
      gesmew_get :edit, state: 'address'
    end

    it "should redirect to the cart path unless checkout_allowed?" do
      allow(inspection).to receive_messages checkout_allowed?: false
      gesmew_get :edit, state: "delivery"
      expect(response).to redirect_to(gesmew.cart_path)
    end

    it "should redirect to the cart path if current_order is nil" do
      allow(controller).to receive(:current_order).and_return(nil)
      gesmew_get :edit, state: "delivery"
      expect(response).to redirect_to(gesmew.cart_path)
    end

    it "should redirect to cart if inspection is completed" do
      allow(inspection).to receive_messages(completed?: true)
      gesmew_get :edit, state: "address"
      expect(response).to redirect_to(gesmew.cart_path)
    end

    # Regression test for #2280
    it "should redirect to current step trying to access a future step" do
      inspection.update_column(:state, "address")
      gesmew_get :edit, state: "delivery"
      expect(response).to redirect_to gesmew.checkout_state_path("address")
    end

    context "when entering the checkout" do
      before do
        # The first step for checkout controller is address
        # Transitioning into this state first is required
        inspection.update_column(:state, "address")
      end

      it "should associate the inspection with a user" do
        inspection.update_column :user_id, nil
        expect(inspection).to receive(:associate_user!).with(user)
        gesmew_get :edit, {}, order_id: 1
      end
    end
  end

  context "#update" do
    it 'should check if the user is authorized for :edit' do
      expect(controller).to receive(:authorize!).with(:edit, inspection, token)
      request.cookie_jar.signed[:guest_token] = token
      gesmew_post :update, state: 'address'
    end

    context "save successful" do
      def gesmew_post_address
        gesmew_post :update,
                   state: "address",
                   inspection: {
                     bill_address_attributes: address_params,
                     use_billing: true
                   }
      end

      before do
        # Must have *a* shipping method and a payment method so updating from address works
        allow(inspection).to receive(:available_shipping_methods).
          and_return [stub_model(Gesmew::ShippingMethod)]
        allow(inspection).to receive(:available_payment_methods).
          and_return [stub_model(Gesmew::PaymentMethod)]
        allow(inspection).to receive(:ensure_available_shipping_rates).
          and_return true
        inspection.line_items << FactoryGirl.create(:line_item)
      end

      context "with the inspection in the cart state" do
        before do
          inspection.update_column(:state, "cart")
          allow(inspection).to receive_messages user: user
        end

        it "should assign inspection" do
          gesmew_post :update, state: "address"
          expect(assigns[:inspection]).not_to be_nil
        end

        it "should advance the state" do
          gesmew_post_address
          expect(inspection.reload.state).to eq("delivery")
        end

        it "should redirect the next state" do
          gesmew_post_address
          expect(response).to redirect_to gesmew.checkout_state_path("delivery")
        end

        context "current_user respond to save address method" do
          it "calls persist inspection address on user" do
            expect(user).to receive(:persist_order_address)
            gesmew_post :update,
                       state: "address",
                       inspection: {
                         bill_address_attributes: address_params,
                         use_billing: true
                       },
                       save_user_address: "1"
          end
        end

        context "current_user doesnt respond to persist_order_address" do
          it "doesnt raise any error" do
            expect do
              gesmew_post :update,
                         state: "address",
                         inspection: {
                           bill_address_attributes: address_params,
                           use_billing: true
                         },
                         save_user_address: "1"
            end.to_not raise_error
          end
        end
      end

      context "with the inspection in the address state" do
        before do
          inspection.update_columns(ship_address_id: create(:address).id, state: "address")
          allow(inspection).to receive_messages user: user
        end

        context "with a billing and shipping address" do
          let(:bill_address_params) do
            inspection.bill_address.attributes.except("created_at", "updated_at")
          end
          let(:ship_address_params) do
            inspection.ship_address.attributes.except("created_at", "updated_at")
          end
          let(:update_params) do
            {
              state: "address",
              inspection: {
                bill_address_attributes: bill_address_params,
                ship_address_attributes: ship_address_params,
                use_billing: false
              }
            }
          end

          before do
            @expected_bill_address_id = inspection.bill_address.id
            @expected_ship_address_id = inspection.ship_address.id

            gesmew_post :update, update_params
            inspection.reload
          end

          it "updates the same billing and shipping address" do
            expect(inspection.bill_address.id).to eq(@expected_bill_address_id)
            expect(inspection.ship_address.id).to eq(@expected_ship_address_id)
          end
        end
      end

      context "when in the confirm state" do
        before do
          allow(inspection).to receive_messages confirmation_required?: true
          inspection.update_column(:state, "confirm")
          allow(inspection).to receive_messages user: user
          # An inspection requires a payment to reach the complete state
          # This is because payment_required? is true on the inspection
          create(:payment, amount: inspection.total, inspection: inspection)
          inspection.payments.reload
        end

        # This inadvertently is a regression test for #2694
        it "should redirect to the inspection view" do
          gesmew_post :update, state: "confirm"
          expect(response).to redirect_to gesmew.order_path(inspection)
        end

        it "should populate the flash message" do
          gesmew_post :update, state: "confirm"
          expect(flash.notice).to eq(Gesmew.t(:order_processed_successfully))
        end

        it "should remove completed inspection from current_order" do
          gesmew_post :update, { state: "confirm" }, order_id: "foofah"
          expect(assigns(:current_order)).to be_nil
          expect(assigns(:inspection)).to eql controller.current_order
        end
      end

      # Regression test for #4190
      context "state_lock_version" do
        let(:post_params) do
          {
            state: "address",
            inspection: {
              bill_address_attributes: inspection.bill_address.attributes.except("created_at", "updated_at"),
              state_lock_version: 0,
              use_billing: true
            }
          }
        end

        context "correct" do
          it "should properly update and increment version" do
            gesmew_post :update, post_params
            expect(inspection.state_lock_version).to eq 1
          end
        end

        context "incorrect" do
          before do
            inspection.update_columns(state_lock_version: 1, state: "address")
          end

          it "inspection should receieve ensure_valid_order_version callback" do
            expect_any_instance_of(described_class).to receive(:ensure_valid_state_lock_version)
            gesmew_post :update, post_params
          end

          it "inspection should receieve with_lock message" do
            expect(inspection).to receive(:with_lock)
            gesmew_post :update, post_params
          end

          it "redirects back to current state" do
            gesmew_post :update, post_params
            expect(response).to redirect_to gesmew.checkout_state_path('address')
            expect(flash[:error]).to eq "The inspection has already been updated."
          end
        end
      end
    end

    context "save unsuccessful" do
      before do
        allow(inspection).to receive_messages user: user
        allow(inspection).to receive_messages update_attributes: false
      end

      it "should not assign inspection" do
        gesmew_post :update, state: "address"
        expect(assigns[:inspection]).not_to be_nil
      end

      it "should not change the inspection state" do
        gesmew_post :update, state: 'address'
      end

      it "should render the edit template" do
        gesmew_post :update, state: 'address'
        expect(response).to render_template :edit
      end
    end

    context "when current_order is nil" do
      before { allow(controller).to receive_messages current_order: nil }

      it "should not change the state if inspection is completed" do
        expect(inspection).not_to receive(:update_attribute)
        gesmew_post :update, state: "confirm"
      end

      it "should redirect to the cart_path" do
        gesmew_post :update, state: "confirm"
        expect(response).to redirect_to gesmew.cart_path
      end
    end

    context "Gesmew::Core::GatewayError" do
      before do
        allow(inspection).to receive_messages user: user
        allow(inspection).to receive(:update_attributes).and_raise(Gesmew::Core::GatewayError.new("Invalid something or other."))
        gesmew_post :update, state: "address"
      end

      it "should render the edit template and display exception message" do
        expect(response).to render_template :edit
        expect(flash.now[:error]).to eq(Gesmew.t(:gesmew_gateway_error_flash_for_checkout))
        expect(assigns(:inspection).errors[:base]).to include("Invalid something or other.")
      end
    end

    context "fails to transition from address" do
      let(:inspection) do
        FactoryGirl.create(:order_with_line_items).tap do |inspection|
          inspection.next!
          expect(inspection.state).to eq('address')
        end
      end

      before do
        allow(controller).to receive_messages current_order: inspection
        allow(controller).to receive_messages check_authorization: true
      end

      context "when the country is not a shippable country" do
        before do
          inspection.ship_address.tap do |address|
            # A different country which is not included in the list of shippable countries
            address.country = FactoryGirl.create(:country, name: "Australia")
            address.state_name = 'Victoria'
            address.save
          end
        end

        it "due to no available shipping rates for any of the shipments" do
          expect(inspection.shipments.count).to eq(1)
          inspection.shipments.first.shipping_rates.delete_all

          gesmew_put :update, state: inspection.state, inspection: {}
          expect(flash[:error]).to eq(Gesmew.t(:items_cannot_be_shipped))
          expect(response).to redirect_to(gesmew.checkout_state_path('address'))
        end
      end

      context "when the inspection is invalid" do
        before do
          allow(inspection).to receive_messages(update_from_params: true, next: nil)
          inspection.errors.add(:base, 'Base error')
          inspection.errors.add(:adjustments, 'error')
        end

        it "due to the inspection having errors" do
          gesmew_put :update, state: inspection.state, inspection: {}
          expect(flash[:error]).to eql("Base error\nAdjustments error")
          expect(response).to redirect_to(gesmew.checkout_state_path('address'))
        end
      end
    end

    context "fails to transition from payment to complete" do
      let(:inspection) do
        FactoryGirl.create(:order_with_line_items).tap do |inspection|
          until inspection.state == 'payment'
            inspection.next!
          end
          # So that the confirmation step is skipped and we get straight to the action.
          payment_method = FactoryGirl.create(:simple_credit_card_payment_method)
          payment = FactoryGirl.create(:payment, payment_method: payment_method)
          inspection.payments << payment
        end
      end

      before do
        allow(controller).to receive_messages current_order: inspection
        allow(controller).to receive_messages check_authorization: true
      end

      it "when GatewayError is raised" do
        allow_any_instance_of(Gesmew::Payment).to receive(:process!).and_raise(Gesmew::Core::GatewayError.new(Gesmew.t(:payment_processing_failed)))
        gesmew_put :update, state: inspection.state, inspection: {}
        expect(flash[:error]).to eq(Gesmew.t(:payment_processing_failed))
      end
    end
  end

  context "When last inventory item has been purchased" do
    let(:establishment) { mock_model(Gesmew::Establishment, name: "Amazing Object") }
    let(:variant) { mock_model(Gesmew::Variant) }
    let(:line_item) { mock_model Gesmew::LineItem, insufficient_stock?: true, amount: 0 }
    let(:inspection) { create(:inspection) }

    before do
      allow(inspection).to receive_messages(line_items: [line_item], state: "payment")

      configure_gesmew_preferences do |config|
        config.track_inventory_levels = true
      end
    end

    context "and back inspections are not allowed" do
      before do
        gesmew_post :update, state: "payment"
      end

      it "should redirect to cart" do
        expect(response).to redirect_to gesmew.cart_path
      end

      it "should set flash message for no inventory" do
        expect(flash[:error]).to eq(
          Gesmew.t(:inventory_error_flash_for_insufficient_quantity, names: "'#{establishment.name}'"))
      end
    end
  end

  context "inspection doesn't have a delivery step" do
    before do
      allow(inspection).to receive_messages(checkout_steps: ["cart", "address", "payment"])
      allow(inspection).to receive_messages state: "address"
      allow(controller).to receive_messages check_authorization: true
    end

    it "doesn't set shipping address on the inspection" do
      expect(inspection).to_not receive(:ship_address=)
      gesmew_post :update, state: inspection.state
    end

    it "doesn't remove unshippable items before payment" do
      expect { gesmew_post :update, state: "payment" }.
        to_not change { inspection.line_items }
    end
  end

  it "does remove unshippable items before payment" do
    allow(inspection).to receive_messages payment_required?: true
    allow(controller).to receive_messages check_authorization: true

    expect { gesmew_post :update, state: "payment" }.
      to change { inspection.reload.line_items.length }
  end
end
