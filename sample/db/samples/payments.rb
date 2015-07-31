# create payments based on the totals since they can't be known in YAML (quantities are random)
method = Gesmew::PaymentMethod.where(:name => 'Credit Card', :active => true).first

# Hack the current method so we're able to return a gateway without a RAILS_ENV
Gesmew::Gateway.class_eval do
  def self.current
    Gesmew::Gateway::Bogus.new
  end
end

# This table was previously called gesmew_creditcards, and older migrations
# reference it as such. Make it explicit here that this table has been renamed.
Gesmew::CreditCard.table_name = 'gesmew_credit_cards'

creditcard = Gesmew::CreditCard.create(:cc_type => 'visa', :month => 12, :year => 2.years.from_now.year, :last_digits => '1111',
                                      :name => 'Sean Schofield', :gateway_customer_profile_id => 'BGS-1234')

Gesmew::Order.all.each_with_index do |order, index|
  order.update!
  payment = order.payments.create!(:amount => order.total, :source => creditcard.clone, :payment_method => method)
  payment.update_columns(:state => 'pending', :response_code => '12345')
end
