Gesmew::Sample.load_sample("addresses")

orders = []
orders << Gesmew::Order.create!(
  :number => "R123456789",
  :email => "gesmew@example.com",
  :item_total => 150.95,
  :adjustment_total => 150.95,
  :total => 301.90,
  :shipping_address => Gesmew::Address.first,
  :billing_address => Gesmew::Address.last)

orders << Gesmew::Order.create!(
  :number => "R987654321",
  :email => "gesmew@example.com",
  :item_total => 15.95,
  :adjustment_total => 15.95,
  :total => 31.90,
  :shipping_address => Gesmew::Address.first,
  :billing_address => Gesmew::Address.last)

orders[0].line_items.create!(
  :variant => Gesmew::Product.find_by_name!("Ruby on Rails Tote").master,
  :quantity => 1,
  :price => 15.99)

orders[1].line_items.create!(
  :variant => Gesmew::Product.find_by_name!("Ruby on Rails Bag").master,
  :quantity => 1,
  :price => 22.99)

orders.each(&:create_proposed_shipments)

orders.each do |order|
  order.state = "complete"
  order.completed_at = Time.now - 1.day
  order.save!
end
