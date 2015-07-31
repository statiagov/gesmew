united_states = Gesmew::Country.find_by_iso!("US")
new_york = Gesmew::State.find_by_name!("New York")

# Billing address
Gesmew::Address.create!(
  firstname: FFaker::Name.first_name,
  lastname: FFaker::Name.last_name,
  address1: FFaker::Address.street_address,
  address2: FFaker::Address.secondary_address,
  city: FFaker::Address.city,
  state: new_york,
  zipcode: 16804,
  country: united_states,
  phone: FFaker::PhoneNumber.phone_number)

#Shipping address
Gesmew::Address.create!(
  firstname: FFaker::Name.first_name,
  lastname: FFaker::Name.last_name,
  address1: FFaker::Address.street_address,
  address2: FFaker::Address.secondary_address,
  city: FFaker::Address.city,
  state: new_york,
  zipcode: 16804,
  country: united_states,
  phone: FFaker::PhoneNumber.phone_number)
