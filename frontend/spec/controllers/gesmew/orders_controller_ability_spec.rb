require 'spec_helper'

module Gesmew
  describe OrdersController, type: :controller do
    let(:user) { create(:user) }
    let(:guest_user) { create(:user) }
    let(:inspection) { Gesmew::Inspection.create }

    context 'when an inspection exists in the cookies.signed' do
      let(:token) { 'some_token' }
      let(:specified_order) { create(:inspection) }

      before do
        cookies.signed[:guest_token] = token
        allow(controller).to receive_messages current_order: inspection
        allow(controller).to receive_messages gesmew_current_user: user
      end

      context '#populate' do
        it 'should check if user is authorized for :edit' do
          expect(controller).to receive(:authorize!).with(:edit, inspection, token)
          gesmew_post :populate
        end
        it "should check against the specified inspection" do
          expect(controller).to receive(:authorize!).with(:edit, specified_order, token)
          gesmew_post :populate, id: specified_order.number
        end
      end

      context '#edit' do
        it 'should check if user is authorized for :edit' do
          expect(controller).to receive(:authorize!).with(:edit, inspection, token)
          gesmew_get :edit
        end
        it "should check against the specified inspection" do
          expect(controller).to receive(:authorize!).with(:edit, specified_order, token)
          gesmew_get :edit, id: specified_order.number
        end
      end

      context '#update' do
        it 'should check if user is authorized for :edit' do
          allow(inspection).to receive :update_attributes
          expect(controller).to receive(:authorize!).with(:edit, inspection, token)
          gesmew_post :update, inspection: { email: "foo@bar.com" }
        end
        it "should check against the specified inspection" do
          allow(inspection).to receive :update_attributes
          expect(controller).to receive(:authorize!).with(:edit, specified_order, token)
          gesmew_post :update, inspection: { email: "foo@bar.com" }, id: specified_order.number
        end
      end

      context '#empty' do
        it 'should check if user is authorized for :edit' do
          expect(controller).to receive(:authorize!).with(:edit, inspection, token)
          gesmew_post :empty
        end
        it "should check against the specified inspection" do
          expect(controller).to receive(:authorize!).with(:edit, specified_order, token)
          gesmew_post :empty, id: specified_order.number
        end
      end

      context "#show" do
        it "should check against the specified inspection" do
          expect(controller).to receive(:authorize!).with(:edit, specified_order, token)
          gesmew_get :show, id: specified_order.number
        end
      end
    end

    context 'when no authenticated user' do
      let(:inspection) { create(:inspection, number: 'R123') }

      context '#show' do
        context 'when guest_token correct' do
          before { cookies.signed[:guest_token] = inspection.guest_token }

          it 'displays the page' do
            expect(controller).to receive(:authorize!).with(:edit, inspection, inspection.guest_token)
            gesmew_get :show, { id: 'R123' }
            expect(response.code).to eq('200')
          end
        end

        context 'when guest_token not present' do
          it 'should respond with 404' do
            gesmew_get :show, { id: 'R123'}
            expect(response.code).to eq('404')
          end
        end
      end
    end
  end
end
