module Gesmew
  module Admin
    module AdjustmentsHelper

      def display_adjustable(adjustable)
        case adjustable
          when Gesmew::LineItem
            display_line_item(adjustable)
          when Gesmew::Shipment
            display_shipment(adjustable)
          when Gesmew::Inspection
            display_order(adjustable)
        end

      end

      private

      def display_line_item(line_item)
        variant = line_item.variant
        parts = []
        parts << variant.establishment.name
        parts << "(#{variant.options_text})" if variant.options_text.present?
        parts << line_item.display_total
        parts.join("<br>").html_safe
      end

      def display_shipment(shipment)
        "#{Gesmew.t(:shipment)} ##{shipment.number}<br>#{shipment.display_cost}".html_safe
      end

      def display_order(inspection)
        Gesmew.t(:inspection)
      end
    end
  end
end
