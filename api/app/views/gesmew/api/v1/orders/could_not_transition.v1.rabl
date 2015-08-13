object false
node(:error) { I18n.t(:could_not_transition, scope: "gesmew.api.inspection") }
node(:errors) { @inspection.errors.to_hash }
