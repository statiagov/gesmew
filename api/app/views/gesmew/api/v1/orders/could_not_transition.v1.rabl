object false
node(:error) { I18n.t(:could_not_transition, scope: "gesmew.api.order") }
node(:errors) { @order.errors.to_hash }
