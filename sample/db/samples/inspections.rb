Gesmew::Sample.load_sample("addresses")

inspections = []
inspections << Gesmew::Inspection.create!(
  :number => "R123456789",
  :email => "gesmew@example.com",
  :item_total => 150.95,
  :adjustment_total => 150.95,
  :total => 301.90,
  :shipping_address => Gesmew::Address.first,
  :billing_address => Gesmew::Address.last)

inspections << Gesmew::Inspection.create!(
  :number => "R987654321",
  :email => "gesmew@example.com",
  :item_total => 15.95,
  :adjustment_total => 15.95,
  :total => 31.90,
  :shipping_address => Gesmew::Address.first,
  :billing_address => Gesmew::Address.last)

inspections[0].line_items.create!(
  :variant => Gesmew::Establishment.find_by_name!("Ruby on Rails Tote").master,
  :quantity => 1,
  :price => 15.99)

inspections[1].line_items.create!(
  :variant => Gesmew::Establishment.find_by_name!("Ruby on Rails Bag").master,
  :quantity => 1,
  :price => 22.99)

inspections.each(&:create_proposed_shipments)

inspections.each do |inspection|
  inspection.state = "complete"
  inspection.completed_at = Time.now - 1.day
  inspection.save!
end
