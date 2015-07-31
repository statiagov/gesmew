Gesmew::Sample.load_sample("orders")

first_order = Gesmew::Order.find_by_number!("R123456789")
last_order = Gesmew::Order.find_by_number!("R987654321")

first_order.adjustments.create!(
  :amount => 0,
  :source => Gesmew::TaxRate.find_by_name!("North America"),
  :order  => first_order,
  :label => "Tax",
  :state => "open",
  :mandatory => true)

last_order.adjustments.create!(
  :amount => 0,
  :source => Gesmew::TaxRate.find_by_name!("North America"),
  :order  => last_order,
  :label => "Tax",
  :state => "open",
  :mandatory => true)
