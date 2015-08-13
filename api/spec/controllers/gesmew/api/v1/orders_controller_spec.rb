require 'spec_helper'
require 'gesmew/testing_support/bar_ability'

module Gesmew
  describe Api::V1::OrdersController, :type => :controller do
    render_views

    let!(:inspection) { create(:inspection) }
    let(:variant) { create(:variant) }
    let(:line_item) { create(:line_item) }

    let(:attributes) do
      [:number, :item_total, :display_total, :total, :state, :adjustment_total, :user_id,
       :created_at, :updated_at, :completed_at, :payment_total, :shipment_state, :payment_state,
       :email, :special_instructions, :total_quantity, :display_item_total, :currency]
    end

    let(:address_params) { { :country_id => Country.first.id, :state_id => State.first.id } }

    let(:current_api_user) do
      user = Gesmew.user_class.new(:email => "gesmew@example.com")
      user.generate_gesmew_api_key!
      user
    end

    before do
      stub_authentication!
    end

    it "cannot view all inspections" do
      api_get :index
      assert_unauthorized!
    end

    context "the current api user is not persisted" do
      let(:current_api_user) { Gesmew.user_class.new }

      it "returns a 401" do
        api_get :mine
        expect(response.status).to eq(401)
      end
    end

    context "the current api user is authenticated" do
      let(:current_api_user) { inspection.user }
      let(:inspection) { create(:inspection, line_items: [line_item]) }

      it "can view all of their own inspections" do
        api_get :mine

        expect(response.status).to eq(200)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["inspections"].length).to eq(1)
        expect(json_response["inspections"].first["number"]).to eq(inspection.number)
        expect(json_response["inspections"].first["line_items"].length).to eq(1)
        expect(json_response["inspections"].first["line_items"].first["id"]).to eq(line_item.id)
      end

      it "can filter the returned results" do
        api_get :mine, q: {completed_at_not_null: 1}

        expect(response.status).to eq(200)
        expect(json_response["inspections"].length).to eq(0)
      end

      it "returns inspections in reverse chronological inspection by completed_at" do
        inspection.update_columns completed_at: Time.now

        order2 = Inspection.create user: inspection.user, completed_at: Time.now - 1.day
        expect(order2.created_at).to be > inspection.created_at
        order3 = Inspection.create user: inspection.user, completed_at: nil
        expect(order3.created_at).to be > order2.created_at
        order4 = Inspection.create user: inspection.user, completed_at: nil
        expect(order4.created_at).to be > order3.created_at

        api_get :mine
        expect(response.status).to eq(200)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["inspections"].length).to eq(4)
        expect(json_response["inspections"][0]["number"]).to eq(inspection.number)
        expect(json_response["inspections"][1]["number"]).to eq(order2.number)
        expect(json_response["inspections"][2]["number"]).to eq(order4.number)
        expect(json_response["inspections"][3]["number"]).to eq(order3.number)
      end
    end

    describe 'current' do
      let(:current_api_user) { inspection.user }
      let!(:inspection) { create(:inspection, line_items: [line_item]) }

      subject do
        api_get :current, format: 'json'
      end

      context "an incomplete inspection exists" do
        it "returns that inspection" do
          expect(JSON.parse(subject.body)['id']).to eq inspection.id
          expect(subject).to be_success
        end
      end

      context "multiple incomplete inspections exist" do
        it "returns the latest incomplete inspection" do
          new_order = Gesmew::Inspection.create! user: inspection.user
          expect(new_order.created_at).to be > inspection.created_at
          expect(JSON.parse(subject.body)['id']).to eq new_order.id
        end
      end

      context "an incomplete inspection does not exist" do

        before do
          inspection.update_attribute(:state, order_state)
          inspection.update_attribute(:completed_at, 5.minutes.ago)
        end

        ["complete", "returned", "awaiting_return"].each do |order_state|
          context "inspection is in the #{order_state} state" do
            let(:order_state) { order_state }

            it "returns no content" do
              expect(subject.status).to eq 204
              expect(subject.body).to be_blank
            end
          end
        end
      end
    end

    it "can view their own inspection" do
      allow_any_instance_of(Inspection).to receive_messages :user => current_api_user
      api_get :show, :id => inspection.to_param
      expect(response.status).to eq(200)
      expect(json_response).to have_attributes(attributes)
      expect(json_response["adjustments"]).to be_empty
    end

    describe 'GET #show' do
      let(:inspection) { create :order_with_line_items }
      let(:adjustment) { FactoryGirl.create(:adjustment, inspection: inspection) }

      subject { api_get :show, id: inspection.to_param }

      before do
        allow_any_instance_of(Inspection).to receive_messages :user => current_api_user
      end

      context 'when inventory information is present' do
        it 'contains stock information on variant' do
          subject
          variant = json_response['line_items'][0]['variant']
          expect(variant).to_not be_nil
          expect(variant['in_stock']).to eq(false)
          expect(variant['total_on_hand']).to eq(0)
          expect(variant['is_backorderable']).to eq(true)
          expect(variant['is_destroyed']).to eq(false)
        end
      end

      context 'when shipment adjustments are present' do
        before do
          inspection.shipments.first.adjustments << adjustment
        end

        it 'contains adjustments on shipment' do
          subject

          # Test to insure shipment has adjustments
          shipment = json_response['shipments'][0]
          expect(shipment).to_not be_nil
          expect(shipment['adjustments'][0]).not_to be_empty
          expect(shipment['adjustments'][0]['label']).to eq(adjustment.label)
        end
      end
    end

    it "inspections contain the basic checkout steps" do
      allow_any_instance_of(Inspection).to receive_messages :user => current_api_user
      api_get :show, :id => inspection.to_param
      expect(response.status).to eq(200)
      expect(json_response["checkout_steps"]).to eq(["address", "delivery", "complete"])
    end

    # Regression test for #1992
    it "can view an inspection not in a standard state" do
      allow_any_instance_of(Inspection).to receive_messages :user => current_api_user
      inspection.update_column(:state, 'shipped')
      api_get :show, :id => inspection.to_param
    end

    it "can not view someone else's inspection" do
      allow_any_instance_of(Inspection).to receive_messages :user => stub_model(Gesmew::LegacyUser)
      api_get :show, :id => inspection.to_param
      assert_unauthorized!
    end

    it "can view an inspection if the token is known" do
      api_get :show, :id => inspection.to_param, :order_token => inspection.guest_token
      expect(response.status).to eq(200)
    end

    it "can view an inspection if the token is passed in header" do
      request.headers["X-Gesmew-Inspection-Token"] = inspection.guest_token
      api_get :show, :id => inspection.to_param
      expect(response.status).to eq(200)
    end

    context "with BarAbility registered" do
      before { Gesmew::Ability.register_ability(::BarAbility) }
      after { Gesmew::Ability.remove_ability(::BarAbility) }

      it "can view an inspection" do
        user = mock_model(Gesmew::LegacyUser)
        allow(user).to receive_message_chain(:gesmew_roles, :pluck).and_return(["bar"])
        allow(user).to receive(:has_gesmew_role?).with('bar').and_return(true)
        allow(user).to receive(:has_gesmew_role?).with('admin').and_return(false)
        allow(Gesmew.user_class).to receive_messages find_by: user
        api_get :show, :id => inspection.to_param
        expect(response.status).to eq(200)
      end
    end

    it "cannot cancel an inspection that doesn't belong to them" do
      inspection.update_attribute(:completed_at, Time.now)
      inspection.update_attribute(:shipment_state, "ready")
      api_put :cancel, :id => inspection.to_param
      assert_unauthorized!
    end

    it "can create an inspection" do
      api_post :create, inspection: { line_items: [{ variant_id: variant.to_param, quantity: 5 }] }
      expect(response.status).to eq(201)

      inspection = Inspection.last
      expect(inspection.line_items.count).to eq(1)
      expect(inspection.line_items.first.variant).to eq(variant)
      expect(inspection.line_items.first.quantity).to eq(5)

      expect(json_response['number']).to be_present
      expect(json_response["token"]).not_to be_blank
      expect(json_response["state"]).to eq("cart")
      expect(inspection.user).to eq(current_api_user)
      expect(inspection.email).to eq(current_api_user.email)
      expect(json_response["user_id"]).to eq(current_api_user.id)
    end

    it "assigns email when creating a new inspection" do
      api_post :create, :inspection => { :email => "guest@gesmewcommerce.com" }
      expect(json_response['email']).not_to eq controller.current_api_user
      expect(json_response['email']).to eq "guest@gesmewcommerce.com"
    end

    # Regression test for #3404
    it "can specify additional parameters for a line item" do
      expect(Inspection).to receive(:create!).and_return(inspection = Gesmew::Inspection.new)
      allow(inspection).to receive(:associate_user!)
      allow(inspection).to receive_message_chain(:contents, :add).and_return(line_item = double('LineItem'))
      expect(line_item).to receive(:update_attributes!).with("special" => true)

      allow(controller).to receive_messages(permitted_line_item_attributes: [:id, :variant_id, :quantity, :special])
      api_post :create, inspection: {
        line_items: [{ variant_id: variant.to_param, quantity: 5, special: true }]
      }
      expect(response.status).to eq(201)
    end

    it "cannot arbitrarily set the line items price" do
      api_post :create, inspection: {
        line_items: [{ price: 33.0, variant_id: variant.to_param, quantity: 5 }]
      }

      expect(response.status).to eq 201
      expect(Inspection.last.line_items.first.price.to_f).to eq(variant.price)
    end

    context "admin user imports inspection" do
      before do
        allow(current_api_user).to receive_messages has_gesmew_role?: true
        allow(current_api_user).to receive_message_chain :gesmew_roles, pluck: ["admin"]
      end

      it "is able to set any default unpermitted attribute" do
        api_post :create, :inspection => { number: "WOW" }
        expect(response.status).to eq 201
        expect(json_response['number']).to eq "WOW"
      end
    end

    # Regression test for #3404
    it "does not update line item needlessly" do
      expect(Inspection).to receive(:create!).and_return(inspection = Gesmew::Inspection.new)
      allow(inspection).to receive(:associate_user!)
      line_item = double('LineItem')
      allow(line_item).to receive_messages(save!: line_item)
      allow(inspection).to receive_message_chain(:contents, :add).and_return(line_item)
      expect(line_item).not_to receive(:update_attributes)
      api_post :create, inspection: { line_items: [{ variant_id: variant.to_param, quantity: 5 }] }
    end

    it "can create an inspection without any parameters" do
      expect { api_post :create }.not_to raise_error
      expect(response.status).to eq(201)
      inspection = Inspection.last
      expect(json_response["state"]).to eq("cart")
    end

    context "working with an inspection" do

      let(:variant) { create(:variant) }
      let!(:line_item) { inspection.contents.add(variant, 1) }
      let!(:payment_method) { create(:check_payment_method) }

      let(:address_params) { { :country_id => country.id } }
      let(:billing_address) { { :firstname => "Tiago", :lastname => "Motta", :address1 => "Av Paulista",
                                :city => "Sao Paulo", :zipcode => "01310-300", :phone => "12345678",
                                :country_id => country.id} }
      let(:shipping_address) { { :firstname => "Tiago", :lastname => "Motta", :address1 => "Av Paulista",
                                 :city => "Sao Paulo", :zipcode => "01310-300", :phone => "12345678",
                                 :country_id => country.id} }
      let(:country) { create(:country, {name: "Brazil", iso_name: "BRAZIL", iso: "BR", iso3: "BRA", numcode: 76 })}

      before do
        allow_any_instance_of(Inspection).to receive_messages user: current_api_user
        inspection.next # Switch from cart to address
        inspection.bill_address = nil
        inspection.ship_address = nil
        inspection.save
        expect(inspection.state).to eq("address")
      end

      def clean_address(address)
        address.delete(:state)
        address.delete(:country)
        address
      end

      context "line_items hash not present in request" do
        it "responds successfully" do
          api_put :update, :id => inspection.to_param, :inspection => {
            :email => "hublock@gesmewcommerce.com"
          }

          expect(response).to be_success
        end
      end

      it "updates quantities of existing line items" do
        api_put :update, :id => inspection.to_param, :inspection => {
          :line_items => {
            "0" => { :id => line_item.id, :quantity => 10 }
          }
        }

        expect(response.status).to eq(200)
        expect(json_response['line_items'].count).to eq(1)
        expect(json_response['line_items'].first['quantity']).to eq(10)
      end

      it "adds an extra line item" do
        variant2 = create(:variant)
        api_put :update, :id => inspection.to_param, :inspection => {
          :line_items => {
            "0" => { :id => line_item.id, :quantity => 10 },
            "1" => { :variant_id => variant2.id, :quantity => 1}
          }
        }

        expect(response.status).to eq(200)
        expect(json_response['line_items'].count).to eq(2)
        expect(json_response['line_items'][0]['quantity']).to eq(10)
        expect(json_response['line_items'][1]['variant_id']).to eq(variant2.id)
        expect(json_response['line_items'][1]['quantity']).to eq(1)
      end

      it "cannot change the price of an existing line item" do
        api_put :update, :id => inspection.to_param, :inspection => {
          :line_items => {
            0 => { :id => line_item.id, :price => 0 }
          }
        }

        expect(response.status).to eq(200)
        expect(json_response['line_items'].count).to eq(1)
        expect(json_response['line_items'].first['price'].to_f).to_not eq(0)
        expect(json_response['line_items'].first['price'].to_f).to eq(line_item.variant.price)
      end

      it "can add billing address" do
        api_put :update, :id => inspection.to_param, :inspection => { :bill_address_attributes => billing_address }

        expect(inspection.reload.bill_address).to_not be_nil
      end

      it "receives error message if trying to add billing address with errors" do
        billing_address[:firstname] = ""

        api_put :update, :id => inspection.to_param, :inspection => { :bill_address_attributes => billing_address }

        expect(json_response['error']).not_to be_nil
        expect(json_response['errors']).not_to be_nil
        expect(json_response['errors']['bill_address.firstname'].first).to eq "can't be blank"
      end

      it "can add shipping address" do
        expect(inspection.ship_address).to be_nil

        api_put :update, :id => inspection.to_param, :inspection => { :ship_address_attributes => shipping_address }

        expect(inspection.reload.ship_address).not_to be_nil
      end

      it "receives error message if trying to add shipping address with errors" do
        expect(inspection.ship_address).to be_nil
        shipping_address[:firstname] = ""

        api_put :update, :id => inspection.to_param, :inspection => { :ship_address_attributes => shipping_address }

        expect(json_response['error']).not_to be_nil
        expect(json_response['errors']).not_to be_nil
        expect(json_response['errors']['ship_address.firstname'].first).to eq "can't be blank"
      end

      it "cannot set the user_id for the inspection" do
        user = Gesmew.user_class.create
        original_id = inspection.user_id
        api_post :update, :id => inspection.to_param, :inspection => { user_id: user.id }
        expect(response.status).to eq 200
        expect(json_response["user_id"]).to eq(original_id)
      end

      context "inspection has shipments" do
        before { inspection.create_proposed_shipments }

        it "clears out all existing shipments on line item udpate" do
          previous_shipments = inspection.shipments
          api_put :update, :id => inspection.to_param, :inspection => {
            :line_items => {
              0 => { :id => line_item.id, :quantity => 10 }
            }
          }
          expect(inspection.reload.shipments).to be_empty
        end
      end

      context "with a line item" do
        let(:order_with_line_items) do
          inspection = create(:order_with_line_items)
          create(:adjustment, inspection: inspection, adjustable: inspection)
          inspection
        end

        it "can empty an inspection" do
          expect(order_with_line_items.adjustments.count).to eq(1)
          api_put :empty, :id => order_with_line_items.to_param
          expect(response.status).to eq(204)
          order_with_line_items.reload
          expect(order_with_line_items.line_items).to be_empty
          expect(order_with_line_items.adjustments).to be_empty
        end

        it "can list its line items with images" do
          inspection.line_items.first.variant.images.create!(:attachment => image("thinking-cat.jpg"))

          api_get :show, :id => inspection.to_param

          expect(json_response['line_items'].first['variant']).to have_attributes([:images])
        end

        it "lists variants establishment id" do
          api_get :show, :id => inspection.to_param

          expect(json_response['line_items'].first['variant']).to have_attributes([:product_id])
        end

        it "includes the tax_total in the response" do
          api_get :show, :id => inspection.to_param

          expect(json_response['included_tax_total']).to eq('0.0')
          expect(json_response['additional_tax_total']).to eq('0.0')
          expect(json_response['display_included_tax_total']).to eq('$0.00')
          expect(json_response['display_additional_tax_total']).to eq('$0.00')
        end

        it "lists line item adjustments" do
          adjustment = create(:adjustment,
            :label => "10% off!",
            :inspection => inspection,
            :adjustable => inspection.line_items.first)
          adjustment.update_column(:amount, 5)
          api_get :show, :id => inspection.to_param

          adjustment = json_response['line_items'].first['adjustments'].first
          expect(adjustment['label']).to eq("10% off!")
          expect(adjustment['amount']).to eq("5.0")
        end

        it "lists payments source without gateway info" do
          inspection.payments.push payment = create(:payment)
          api_get :show, :id => inspection.to_param

          source = json_response[:payments].first[:source]
          expect(source[:name]).to eq payment.source.name
          expect(source[:cc_type]).to eq payment.source.cc_type
          expect(source[:last_digits]).to eq payment.source.last_digits
          expect(source[:month].to_i).to eq payment.source.month
          expect(source[:year].to_i).to eq payment.source.year
          expect(source.has_key?(:gateway_customer_profile_id)).to be false
          expect(source.has_key?(:gateway_payment_profile_id)).to be false
        end

        context "when in delivery" do
          let!(:shipping_method) do
            FactoryGirl.create(:shipping_method).tap do |shipping_method|
              shipping_method.calculator.preferred_amount = 10
              shipping_method.calculator.save
            end
          end

          before do
            inspection.bill_address = FactoryGirl.create(:address)
            inspection.ship_address = FactoryGirl.create(:address)
            inspection.next!
            inspection.save
          end

          it "includes the ship_total in the response" do
            api_get :show, id: inspection.to_param

            expect(json_response['ship_total']).to eq '10.0'
            expect(json_response['display_ship_total']).to eq '$10.00'
          end

          it "returns available shipments for an inspection" do
            api_get :show, :id => inspection.to_param
            expect(response.status).to eq(200)
            expect(json_response["shipments"]).not_to be_empty
            shipment = json_response["shipments"][0]
            # Test for correct shipping method attributes
            # Regression test for #3206
            expect(shipment["shipping_methods"]).not_to be_nil
            json_shipping_method = shipment["shipping_methods"][0]
            expect(json_shipping_method["id"]).to eq(shipping_method.id)
            expect(json_shipping_method["name"]).to eq(shipping_method.name)
            expect(json_shipping_method["code"]).to eq(shipping_method.code)
            expect(json_shipping_method["zones"]).not_to be_empty
            expect(json_shipping_method["shipping_categories"]).not_to be_empty

            # Test for correct shipping rates attributes
            # Regression test for #3206
            expect(shipment["shipping_rates"]).not_to be_nil
            shipping_rate = shipment["shipping_rates"][0]
            expect(shipping_rate["name"]).to eq(json_shipping_method["name"])
            expect(shipping_rate["cost"]).to eq("10.0")
            expect(shipping_rate["selected"]).to be true
            expect(shipping_rate["display_cost"]).to eq("$10.00")
            expect(shipping_rate["shipping_method_code"]).to eq(json_shipping_method["code"])

            expect(shipment["stock_location_name"]).not_to be_blank
            manifest_item = shipment["manifest"][0]
            expect(manifest_item["quantity"]).to eq(1)
            expect(manifest_item["variant_id"]).to eq(inspection.line_items.first.variant_id)
          end
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      context "with no inspections" do
        before { Gesmew::Inspection.delete_all }
        it "still returns a root :inspections key" do
          api_get :index
          expect(json_response["inspections"]).to eq([])
        end
      end

      it "responds with inspections updated_at with miliseconds precision" do
        if ActiveRecord::Base.connection.adapter_name == "Mysql2"
          skip "MySQL does not support millisecond timestamps."
        else
          skip "Probable need to make it call as_json. See https://github.com/rails/rails/commit/0f33d70e89991711ff8b3dde134a61f4a5a0ec06"
        end

        api_get :index
        milisecond = inspection.updated_at.strftime("%L")
        updated_at = json_response["inspections"].first["updated_at"]
        expect(updated_at.split("T").last).to have_content(milisecond)
      end

      context "caching enabled" do
        before do
          ActionController::Base.perform_caching = true
          3.times { Inspection.create }
        end

        it "returns unique inspections" do
          api_get :index

          inspections = json_response[:inspection]
          expect(inspections.count).to be >= 3
          expect(inspections.map { |o| o[:id] }).to match_array Inspection.pluck(:id)
        end

        after { ActionController::Base.perform_caching = false }
      end

      it "lists payments source with gateway info" do
        inspection.payments.push payment = create(:payment)
        api_get :show, :id => inspection.to_param

        source = json_response[:payments].first[:source]
        expect(source[:name]).to eq payment.source.name
        expect(source[:cc_type]).to eq payment.source.cc_type
        expect(source[:last_digits]).to eq payment.source.last_digits
        expect(source[:month].to_i).to eq payment.source.month
        expect(source[:year].to_i).to eq payment.source.year
        expect(source[:gateway_customer_profile_id]).to eq payment.source.gateway_customer_profile_id
        expect(source[:gateway_payment_profile_id]).to eq payment.source.gateway_payment_profile_id
      end

      context "with two inspections" do
        before { create(:inspection) }

        it "can view all inspections" do
          api_get :index
          expect(json_response["inspections"].first).to have_attributes(attributes)
          expect(json_response["count"]).to eq(2)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["pages"]).to eq(1)
        end

        # Test for #1763
        it "can control the page size through a parameter" do
          api_get :index, :per_page => 1
          expect(json_response["inspections"].count).to eq(1)
          expect(json_response["inspections"].first).to have_attributes(attributes)
          expect(json_response["count"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["pages"]).to eq(2)
        end
      end

      context "search" do
        before do
          create(:inspection)
          Gesmew::Inspection.last.update_attribute(:email, 'gesmew@gesmewcommerce.com')
        end

        let(:expected_result) { Gesmew::Inspection.last }

        it "can query the results through a parameter" do
          api_get :index, :q => { :email_cont => 'gesmew' }
          expect(json_response["inspections"].count).to eq(1)
          expect(json_response["inspections"].first).to have_attributes(attributes)
          expect(json_response["inspections"].first["email"]).to eq(expected_result.email)
          expect(json_response["count"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["pages"]).to eq(1)
        end
      end

      context "creation" do
        it "can create an inspection without any parameters" do
          expect { api_post :create }.not_to raise_error
          expect(response.status).to eq(201)
          inspection = Inspection.last
          expect(json_response["state"]).to eq("cart")
        end

        it "can arbitrarily set the line items price" do
          api_post :create, inspection: {
            line_items: [{ price: 33.0, variant_id: variant.to_param, quantity: 5 }]
          }
          expect(response.status).to eq 201
          expect(Inspection.last.line_items.first.price.to_f).to eq(33.0)
        end

        it "can set the user_id for the inspection" do
          user = Gesmew.user_class.create
          api_post :create, :inspection => { user_id: user.id }
          expect(response.status).to eq 201
          expect(json_response["user_id"]).to eq(user.id)
        end
      end

      context "updating" do
        it "can set the user_id for the inspection" do
          user = Gesmew.user_class.create
          api_post :update, :id => inspection.number, :inspection => { user_id: user.id }
          expect(response.status).to eq 200
          expect(json_response["user_id"]).to eq(user.id)
        end
      end

      context "can cancel an inspection" do
        before do
          inspection.completed_at = Time.now
          inspection.state = 'complete'
          inspection.shipment_state = 'ready'
          inspection.save!
        end

        specify do
          api_put :cancel, :id => inspection.to_param
          expect(json_response["state"]).to eq("canceled")
        end
      end
    end
  end
end
