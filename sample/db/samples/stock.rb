Gesmew::Sample.load_sample("variants")

country =  Gesmew::Country.find_by(iso: 'US')
location = Gesmew::StockLocation.first_or_create! name: 'default', address1: 'Example Street', city: 'City', zipcode: '12345', country: country, state: country.states.first
location.active = true
location.save!

Gesmew::Variant.all.each do |variant|
  variant.stock_items.each do |stock_item|
    Gesmew::StockMovement.create(:quantity => 10, :stock_item => stock_item)
  end
end
