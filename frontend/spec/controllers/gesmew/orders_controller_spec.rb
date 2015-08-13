require 'spec_helper'

describe Gesmew::OrdersController, :type => :controller do
  let(:user) { create(:user) }

  context "Inspection model mock" do
    let(:inspection) do
      Gesmew::Inspection.create!
    end
    let(:variant) { create(:variant) }

    before do
      allow(controller).to receive_messages(:try_gesmew_current_user => user)
    end

    context "#populate" do
      it "should create a new inspection when none specified" do
        gesmew_post :populate, {}, {}
        expect(cookies.signed[:guest_token]).not_to be_blank
        expect(Gesmew::Inspection.find_by_guest_token(cookies.signed[:guest_token])).to be_persisted
      end

      context "with Variant" do
        it "should handle population" do
          expect do
            gesmew_post :populate, variant_id: variant.id, quantity: 5
          end.to change { user.inspections.count }.by(1)
          inspection = user.inspections.last
          expect(response).to redirect_to gesmew.cart_path
          expect(inspection.line_items.size).to eq(1)
          line_item = inspection.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(5)
        end

        it "shows an error when population fails" do
          request.env["HTTP_REFERER"] = '/dummy_redirect'
          allow_any_instance_of(Gesmew::LineItem).to(
            receive(:valid?).and_return(false)
          )
          allow_any_instance_of(Gesmew::LineItem).to(
            receive_message_chain(:errors, :full_messages).
              and_return(["Inspection population failed"])
          )

          gesmew_post :populate, variant_id: variant.id, quantity: 5

          expect(response).to redirect_to('/dummy_redirect')
          expect(flash[:error]).to eq("Inspection population failed")
        end

        it "shows an error when quantity is invalid" do
          request.env["HTTP_REFERER"] = '/dummy_redirect'

          gesmew_post(
            :populate,
            variant_id: variant.id, quantity: -1
          )

          expect(response).to redirect_to('/dummy_redirect')
          expect(flash[:error]).to eq(
            Gesmew.t(:please_enter_reasonable_quantity)
          )
        end
      end
    end

    context "#update" do
      context "with authorization" do
        before do
          allow(controller).to receive :check_authorization
          allow(controller).to receive_messages current_order: inspection
        end

        it "should render the edit view (on failure)" do
          # email validation is only after address state
          inspection.update_column(:state, "delivery")
          gesmew_put :update, { :inspection => { :email => "" } }, { :order_id => inspection.id }
          expect(response).to render_template :edit
        end

        it "should redirect to cart path (on success)" do
          allow(inspection).to receive(:update_attributes).and_return true
          gesmew_put :update, {}, {:order_id => 1}
          expect(response).to redirect_to(gesmew.cart_path)
        end
      end
    end

    context "#empty" do
      before do
        allow(controller).to receive :check_authorization
      end

      it "should destroy line items in the current inspection" do
        allow(controller).to receive(:current_order).and_return(inspection)
        expect(inspection).to receive(:empty!)
        gesmew_put :empty
        expect(response).to redirect_to(gesmew.cart_path)
      end
    end

    # Regression test for #2750
    context "#update" do
      before do
        allow(user).to receive :last_incomplete_gesmew_order
        allow(controller).to receive :set_current_order
      end

      it "cannot update a blank inspection" do
        gesmew_put :update, :inspection => { :email => "foo" }
        expect(flash[:error]).to eq(Gesmew.t(:order_not_found))
        expect(response).to redirect_to(gesmew.root_path)
      end
    end
  end

  context "line items quantity is 0" do
    let(:inspection) { Gesmew::Inspection.create }
    let(:variant) { create(:variant) }
    let!(:line_item) { inspection.contents.add(variant, 1) }

    before do
      allow(controller).to receive(:check_authorization)
      allow(controller).to receive_messages(:current_order => inspection)
    end

    it "removes line items on update" do
      expect(inspection.line_items.count).to eq 1
      gesmew_put :update, :inspection => { line_items_attributes: { "0" => { id: line_item.id, quantity: 0 } } }
      expect(inspection.reload.line_items.count).to eq 0
    end
  end
end
