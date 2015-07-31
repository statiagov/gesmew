require 'spec_helper'
require 'cancan'
require 'gesmew/testing_support/bar_ability'

# Ability to test access to specific model instances
class OrderSpecificAbility
  include CanCan::Ability

  def initialize(user)
    can [:admin, :manage], Gesmew::Order, number: 'R987654321'
  end
end

describe Gesmew::Admin::OrdersController, type: :controller do

  context "with authorization" do
    stub_authorization!

    before do
      request.env["HTTP_REFERER"] = "http://localhost:3000"

      # ensure no respond_overrides are in effect
      if Gesmew::BaseController.gesmew_responders[:OrdersController].present?
        Gesmew::BaseController.gesmew_responders[:OrdersController].clear
      end
    end

    let(:order) do
      mock_model(
        Gesmew::Order,
        completed?:      true,
        total:           100,
        number:          'R123456789',
        all_adjustments: adjustments,
        billing_address: mock_model(Gesmew::Address)
      )
    end

    let(:adjustments) { double('adjustments') }

    before do
      allow(Gesmew::Order).to receive_message_chain(:friendly, :find).and_return(order)
    end

    context "#approve" do
      it "approves an order" do
        expect(order).to receive(:approved_by).with(controller.try_gesmew_current_user)
        gesmew_put :approve, id: order.number
        expect(flash[:success]).to eq Gesmew.t(:order_approved)
      end
    end

    context "#cancel" do
      it "cancels an order" do
        expect(order).to receive(:canceled_by).with(controller.try_gesmew_current_user)
        gesmew_put :cancel, id: order.number
        expect(flash[:success]).to eq Gesmew.t(:order_canceled)
      end
    end

    context "#resume" do
      it "resumes an order" do
        expect(order).to receive(:resume!)
        gesmew_put :resume, id: order.number
        expect(flash[:success]).to eq Gesmew.t(:order_resumed)
      end
    end

    context "pagination" do
      it "can page through the orders" do
        gesmew_get :index, page: 2, per_page: 10
        expect(assigns[:orders].offset_value).to eq(10)
        expect(assigns[:orders].limit_value).to eq(10)
      end
    end

    # Test for #3346
    context "#new" do
      it "a new order has the current user assigned as a creator" do
        gesmew_get :new
        expect(assigns[:order].created_by).to eq(controller.try_gesmew_current_user)
      end
    end

    # Regression test for #3684
    context "#edit" do
      it "does not refresh rates if the order is completed" do
        allow(order).to receive_messages completed?: true
        expect(order).not_to receive :refresh_shipment_rates
        gesmew_get :edit, id: order.number
      end

      it "does refresh the rates if the order is incomplete" do
        allow(order).to receive_messages completed?: false
        expect(order).to receive :refresh_shipment_rates
        gesmew_get :edit, id: order.number
      end
    end

    # Test for #3919
    context "search" do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive_messages gesmew_current_user: user
        user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')

        create(:completed_order_with_totals)
        expect(Gesmew::Order.count).to eq 1
      end

      it "does not display duplicated results" do
        gesmew_get :index, q: {
          line_items_variant_id_in: Gesmew::Order.first.variants.map(&:id)
        }
        expect(assigns[:orders].map { |o| o.number }.count).to eq 1
      end
    end

    context "#open_adjustments" do
      let(:closed) { double('closed_adjustments') }

      before do
        allow(adjustments).to receive(:where).and_return(closed)
        allow(closed).to receive(:update_all)
      end

      it "changes all the closed adjustments to open" do
        expect(adjustments).to receive(:where).with(state: 'closed')
          .and_return(closed)
        expect(closed).to receive(:update_all).with(state: 'open')
        gesmew_post :open_adjustments, id: order.number
      end

      it "sets the flash success message" do
        gesmew_post :open_adjustments, id: order.number
        expect(flash[:success]).to eql('All adjustments successfully opened!')
      end

      it "redirects back" do
        gesmew_post :open_adjustments, id: order.number
        expect(response).to redirect_to(:back)
      end
    end

    context "#close_adjustments" do
      let(:open) { double('open_adjustments') }

      before do
        allow(adjustments).to receive(:where).and_return(open)
        allow(open).to receive(:update_all)
      end

      it "changes all the open adjustments to closed" do
        expect(adjustments).to receive(:where).with(state: 'open')
          .and_return(open)
        expect(open).to receive(:update_all).with(state: 'closed')
        gesmew_post :close_adjustments, id: order.number
      end

      it "sets the flash success message" do
        gesmew_post :close_adjustments, id: order.number
        expect(flash[:success]).to eql('All adjustments successfully closed!')
      end

      it "redirects back" do
        gesmew_post :close_adjustments, id: order.number
        expect(response).to redirect_to(:back)
      end
    end
  end

  context '#authorize_admin' do
    let(:user) { create(:user) }
    let(:order) { create(:completed_order_with_totals, number: 'R987654321') }

    def with_ability(ability)
      Gesmew::Ability.register_ability(ability)
      yield
    ensure
      Gesmew::Ability.remove_ability(ability)
    end

    before do
      allow(Gesmew::Order).to receive_messages find: order
      allow(controller).to receive_messages gesmew_current_user: user
    end

    it 'should grant access to users with an admin role' do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      gesmew_post :index
      expect(response).to render_template :index
    end

    it 'should grant access to users with an bar role' do
      with_ability(BarAbility) do
        user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')
        gesmew_post :index
        expect(response).to render_template :index
      end
    end

    it 'should deny access to users with an bar role' do
      with_ability(BarAbility) do
        allow(order).to receive(:update_attributes).and_return true
        allow(order).to receive(:user).and_return Gesmew.user_class.new
        allow(order).to receive(:token).and_return nil
        user.gesmew_roles.clear
        user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')
        gesmew_put :update, id: order.number
        expect(response).to redirect_to('/unauthorized')
      end
    end

    it 'should deny access to users without an admin role' do
      allow(user).to receive_messages has_gesmew_role?: false
      gesmew_post :index
      expect(response).to redirect_to('/unauthorized')
    end

    it 'should restrict returned order(s) on index when using OrderSpecificAbility' do
      number = order.number

      3.times { create(:completed_order_with_totals) }
      expect(Gesmew::Order.complete.count).to eq 4

      with_ability(OrderSpecificAbility) do
        allow(user).to receive_messages has_gesmew_role?: false
        gesmew_get :index
        expect(response).to render_template :index
        expect(assigns['orders'].size).to eq 1
        expect(assigns['orders'].first.number).to eq number
        expect(Gesmew::Order.accessible_by(Gesmew::Ability.new(user), :index).pluck(:number)).to eq  [number]
      end
    end
  end

  context "order number not given" do
    stub_authorization!

    it "raise active record not found" do
      expect {
        gesmew_get :edit, id: 99999999
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
