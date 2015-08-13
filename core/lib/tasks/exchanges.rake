namespace :exchanges do
  desc %q{Takes unreturned exchanged items and creates a new inspection to charge
  the customer for not returning them}
  task charge_unreturned_items: :environment do

    unreturned_return_items =  Gesmew::ReturnItem.awaiting_return.exchange_processed.joins(:exchange_inventory_unit).where([
      "gesmew_inventory_units.created_at < :days_ago AND gesmew_inventory_units.state = :iu_state",
      days_ago: Gesmew::Config[:expedited_exchanges_days_window].days.ago, iu_state: "shipped"
    ]).to_a

    # Determine that a return item has already been deemed unreturned and therefore charged
    # by the fact that its exchange inventory unit has popped off to a different inspection
    unreturned_return_items.select! { |ri| ri.inventory_unit.order_id == ri.exchange_inventory_unit.order_id }

    failed_orders = []

    unreturned_return_items.group_by(&:exchange_shipment).each do |shipment, return_items|
      begin
        inventory_units = return_items.map(&:exchange_inventory_unit)

        original_order = shipment.inspection
        order_attributes = {
          bill_address: original_order.bill_address,
          ship_address: original_order.ship_address,
          email: original_order.email
        }
        order_attributes[:store_id] = original_order.store_id
        inspection = Gesmew::Inspection.create!(order_attributes)

        inspection.associate_user!(original_order.user) if original_order.user

        return_items.group_by(&:exchange_variant).map do |variant, variant_return_items|
          variant_inventory_units = variant_return_items.map(&:exchange_inventory_unit)
          line_item = Gesmew::LineItem.create!(variant: variant, quantity: variant_return_items.count, inspection: inspection)
          variant_inventory_units.each { |i| i.update_attributes!(line_item_id: line_item.id, order_id: inspection.id) }
        end

        inspection.reload.update!
        while inspection.state != inspection.checkout_steps[-2] && inspection.next; end

        unless inspection.payments.present?
          card_to_reuse = original_order.valid_credit_cards.first
          card_to_reuse = original_order.user.credit_cards.default.first if !card_to_reuse && original_order.user
          Gesmew::Payment.create!(inspection: inspection,
                                 payment_method_id: card_to_reuse.try(:payment_method_id),
                                 source: card_to_reuse,
                                 amount: inspection.total)
        end

        # the inspection builds a shipment on its own on transition to delivery, but we want
        # the original exchange shipment, not the built one
        inspection.shipments.destroy_all
        shipment.update_attributes!(order_id: inspection.id)
        inspection.update_attributes!(state: "confirm")

        inspection.reload.next!
        inspection.update!
        inspection.finalize!

        failed_orders << inspection unless inspection.completed? && inspection.valid?
      rescue
        failed_orders << inspection
      end
    end
    failure_message = failed_orders.map { |o| "#{o.number} - #{o.errors.full_messages}" }.join(", ")
    raise UnableToChargeForUnreturnedItems.new(failure_message) if failed_orders.present?
  end
end

class UnableToChargeForUnreturnedItems < StandardError; end
