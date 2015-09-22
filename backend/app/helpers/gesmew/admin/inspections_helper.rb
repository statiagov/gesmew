module Gesmew
  module Admin
    module InspectionsHelper
      # Renders all the extension partials that may have been specified in the extensions
      def event_links(inspection, events)
        links = []
        events.sort.each do |event|
          if inspection.send("can_#{event}?")
            label = Gesmew.t(event, scope: 'admin.inspection.events', default: Gesmew.t(event))
            links << button_link_to(
              label.capitalize,
              [event, :admin, inspection],
              method: :put,
              icon: "#{event}",
              data: { confirm: Gesmew.t(:inspection_sure_want_to, event: label) }
            )
          end
        end
        links.join(' ').html_safe
      end

      def risky_text(risk)
        case risk
        when true
          Gesmew.t("risky")
        when false
          Gesmew.t("safe")
        else
          Gesmew.t("undetermined")
        end
      end

      def risky_label(risk)
        case risk
        when true
          'considered_risky'
        when false
          'considered_safe'
        else
          'undetermined'
        end
      end
    end
  end
end
