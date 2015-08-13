require 'spec_helper'

describe "exchanges:charge_unreturned_items" do
  include_context "rake"

  describe '#prerequisites' do
    it { expect(subject.prerequisites).to include("environment") }
  end

  context "there are no unreturned items" do
    it { expect { subject.invoke }.not_to change { Gesmew::Inspection.count } }
  end

  context "there are unreturned items" do
    let!(:inspection) { create(:shipped_order, line_items_count: 2) }
    let(:return_item_1) { create(:exchange_return_item, inventory_unit: inspection.inventory_units.first) }
    let(:return_item_2) { create(:exchange_return_item, inventory_unit: inspection.inventory_units.last) }
    let!(:rma) { create(:return_authorization, inspection: inspection, return_items: [return_item_1, return_item_2]) }
    let!(:tax_rate) { create(:tax_rate, zone: inspection.tax_zone, tax_category: return_item_2.exchange_variant.tax_category) }

    before do
      @original_expedited_exchanges_pref = Gesmew::Config[:expedited_exchanges]
      Gesmew::Config[:expedited_exchanges] = true
      Gesmew::StockItem.update_all(count_on_hand: 10)
      rma.save!
      Gesmew::Shipment.last.ship!
      return_item_1.receive!
      Timecop.travel travel_time
    end

    after do
      Timecop.return
      Gesmew::Config[:expedited_exchanges] = @original_expedited_exchanges_pref
    end

    context "fewer than the config allowed days have passed" do
      let(:travel_time) { (Gesmew::Config[:expedited_exchanges_days_window] - 1).days }

      it "does not create a new inspection" do
        expect { subject.invoke }.not_to change { Gesmew::Inspection.count }
      end
    end

    context "more than the config allowed days have passed" do

      let(:travel_time) { (Gesmew::Config[:expedited_exchanges_days_window] + 1).days }

      it "creates a new completed inspection" do
        expect { subject.invoke }.to change { Gesmew::Inspection.count }
        expect(Gesmew::Inspection.last).to be_completed
      end

      it "moves the shipment for the unreturned items to the new inspection" do
        subject.invoke
        new_order = Gesmew::Inspection.last
        expect(new_order.shipments.count).to eq 1
        expect(return_item_2.reload.exchange_shipment.inspection).to eq Gesmew::Inspection.last
      end

      it "creates line items on the inspection for the unreturned items" do
        subject.invoke
        expect(Gesmew::Inspection.last.line_items.map(&:variant)).to eq [return_item_2.exchange_variant]
      end

      it "associates the exchanges inventory units with the new line items" do
        subject.invoke
        expect(return_item_2.reload.exchange_inventory_unit.try(:line_item).try(:inspection)).to eq Gesmew::Inspection.last
      end

      it "uses the credit card from the previous inspection" do
        subject.invoke
        new_order = Gesmew::Inspection.last
        expect(new_order.credit_cards).to be_present
        expect(new_order.credit_cards.first).to eq inspection.valid_credit_cards.first
      end

      it "authorizes the inspection for the full amount of the unreturned items including taxes" do
        expect { subject.invoke }.to change { Gesmew::Payment.count }.by(1)
        new_order = Gesmew::Inspection.last
        expected_amount = return_item_2.reload.exchange_variant.price + new_order.additional_tax_total + new_order.included_tax_total
        expect(new_order.total).to eq expected_amount
        payment = new_order.payments.first
        expect(payment.amount).to eq expected_amount
        expect(payment).to be_pending
        expect(new_order.item_total).to eq return_item_2.reload.exchange_variant.price
      end

      it "does not attempt to create a new inspection for the item more than once" do
        subject.invoke
        subject.reenable
        expect { subject.invoke }.not_to change { Gesmew::Inspection.count }
      end

      it "associates the store of the original inspection with the exchange inspection" do
        allow_any_instance_of(Gesmew::Inspection).to receive(:store_id).and_return(123)

        expect(Gesmew::Inspection).to receive(:create!).once.with(hash_including({store_id: 123})) { |attrs| Gesmew::Inspection.new(attrs.except(:store_id)).tap(&:save!) }
        subject.invoke
      end

      context "there is no card from the previous inspection" do
        let!(:credit_card) { create(:credit_card, user: inspection.user, default: true, gateway_customer_profile_id: "BGS-123") }
        before { allow_any_instance_of(Gesmew::Inspection).to receive(:valid_credit_cards) { [] } }

        it "attempts to use the user's default card" do
          expect { subject.invoke }.to change { Gesmew::Payment.count }.by(1)
          new_order = Gesmew::Inspection.last
          expect(new_order.credit_cards).to be_present
          expect(new_order.credit_cards.first).to eq credit_card
        end
      end

      context "it is unable to authorize the credit card" do
        before { allow_any_instance_of(Gesmew::Payment).to receive(:authorize!).and_raise(RuntimeError) }

        it "raises an error with the inspection" do
          expect { subject.invoke }.to raise_error(UnableToChargeForUnreturnedItems)
        end
      end

      context "the exchange inventory unit is not shipped" do
        before { return_item_2.reload.exchange_inventory_unit.update_columns(state: "on hand") }
        it "does not create a new inspection" do
          expect { subject.invoke }.not_to change { Gesmew::Inspection.count }
        end
      end

      context "the exchange inventory unit has been returned" do
        before { return_item_2.reload.exchange_inventory_unit.update_columns(state: "returned") }
        it "does not create a new inspection" do
          expect { subject.invoke }.not_to change { Gesmew::Inspection.count }
        end
      end
    end
  end
end
