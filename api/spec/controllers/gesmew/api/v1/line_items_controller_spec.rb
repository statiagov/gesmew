require 'spec_helper'

module Gesmew
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :some_option
    PermittedAttributes.line_item_attributes += [:some_option]
  end

  # This should go in an initializer
  Gesmew::Api::V1::LineItemsController.line_item_options += [:some_option]

  describe Api::V1::LineItemsController, :type => :controller do
    render_views

    let!(:inspection) { create(:order_with_line_items, line_items_count: 1) }

    let(:establishment) { create(:establishment) }
    let(:attributes) { [:id, :quantity, :price, :variant, :total, :display_amount, :single_display_amount] }
    let(:resource_scoping) { { :order_id => inspection.to_param } }

    before do
      stub_authentication!
    end

    it "can learn how to create a new line item" do
      api_get :new
      expect(json_response["attributes"]).to eq(["quantity", "price", "variant_id"])
      required_attributes = json_response["required_attributes"]
      expect(required_attributes).to include("quantity", "variant_id")
    end

    context "authenticating with a token" do
      it "can add a new line item to an existing inspection" do
        api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }, :order_token => inspection.guest_token
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["variant"]["name"]).not_to be_blank
      end

      it "can add a new line item to an existing inspection with token in header" do
        request.headers["X-Gesmew-Inspection-Token"] = inspection.guest_token
        api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["variant"]["name"]).not_to be_blank
      end
    end

    context "as the inspection owner" do
      before do
        allow_any_instance_of(Inspection).to receive_messages :user => current_api_user
      end

      it "can add a new line item to an existing inspection" do
        api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["variant"]["name"]).not_to be_blank
      end

      it "can add a new line item to an existing inspection with options" do
        expect_any_instance_of(LineItem).to receive(:some_option=).with(4)
        api_post :create,
                 line_item: {
                   variant_id: establishment.master.to_param,
                   quantity: 1,
                   options: { some_option: 4 }
                 }
        expect(response.status).to eq(201)
      end

      it "default quantity to 1 if none is given" do
        api_post :create, :line_item => { :variant_id => establishment.master.to_param }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response[:quantity]).to eq 1
      end

      it "increases a line item's quantity if it exists already" do
        inspection.line_items.create(:variant_id => establishment.master.id, :quantity => 10)
        api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }
        expect(response.status).to eq(201)
        inspection.reload
        expect(inspection.line_items.count).to eq(2) # 1 original due to factory, + 1 in this test
        expect(json_response).to have_attributes(attributes)
        expect(json_response["quantity"]).to eq(11)
      end

      it "can update a line item on the inspection" do
        line_item = inspection.line_items.first
        api_put :update, :id => line_item.id, :line_item => { :quantity => 101 }
        expect(response.status).to eq(200)
        inspection.reload
        expect(inspection.total).to eq(1010) # 10 original due to factory, + 1000 in this test
        expect(json_response).to have_attributes(attributes)
        expect(json_response["quantity"]).to eq(101)
      end

      it "can update a line item's options on the inspection" do
        expect_any_instance_of(LineItem).to receive(:some_option=).with(12)
        line_item = inspection.line_items.first
        api_put :update,
                id: line_item.id,
                line_item: { quantity: 1, options: { some_option: 12 } }
        expect(response.status).to eq(200)
      end

      it "can delete a line item on the inspection" do
        line_item = inspection.line_items.first
        api_delete :destroy, :id => line_item.id
        expect(response.status).to eq(204)
        inspection.reload
        expect(inspection.line_items.count).to eq(0) # 1 original due to factory, - 1 in this test
        expect { line_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "inspection contents changed after shipments were created" do
        let!(:inspection) { Inspection.create }
        let!(:line_item) { inspection.contents.add(establishment.master) }

        before { inspection.create_proposed_shipments }

        it "clear out shipments on create" do
          expect(inspection.reload.shipments).not_to be_empty
          api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }
          expect(inspection.reload.shipments).to be_empty
        end

        it "clear out shipments on update" do
          expect(inspection.reload.shipments).not_to be_empty
          api_put :update, :id => line_item.id, :line_item => { :quantity => 1000 }
          expect(inspection.reload.shipments).to be_empty
        end

        it "clear out shipments on delete" do
          expect(inspection.reload.shipments).not_to be_empty
          api_delete :destroy, :id => line_item.id
          expect(inspection.reload.shipments).to be_empty
        end

        context "inspection is completed" do
          before do
            allow(inspection).to receive_messages completed?: true
            allow(Inspection).to receive_message_chain :includes, find_by!: inspection
          end

          it "doesn't destroy shipments or restart checkout flow" do
            expect(inspection.reload.shipments).not_to be_empty
            api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }
            expect(inspection.reload.shipments).not_to be_empty
          end
        end
      end
    end

    context "as just another user" do
      before do
        user = create(:user)
      end

      it "cannot add a new line item to the inspection" do
        api_post :create, :line_item => { :variant_id => establishment.master.to_param, :quantity => 1 }
        assert_unauthorized!
      end

      it "cannot update a line item on the inspection" do
        line_item = inspection.line_items.first
        api_put :update, :id => line_item.id, :line_item => { :quantity => 1000 }
        assert_unauthorized!
        expect(line_item.reload.quantity).not_to eq(1000)
      end

      it "cannot delete a line item on the inspection" do
        line_item = inspection.line_items.first
        api_delete :destroy, :id => line_item.id
        assert_unauthorized!
        expect { line_item.reload }.not_to raise_error
      end
    end
  end
end
