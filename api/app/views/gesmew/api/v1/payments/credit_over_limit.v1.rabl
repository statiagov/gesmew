object false
node(:error) { I18n.t(:credit_over_limit, :limit => @payment.credit_allowed, :scope => 'gesmew.api.payment') }
