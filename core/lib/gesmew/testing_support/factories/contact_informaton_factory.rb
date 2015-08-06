FactoryGirl.define do
  factory :contact_information, class: Gesmew::ContactInformation do
    firstname {FFaker::Name.first_name}
    lastname  {FFaker::Name.last_name}
    address   {FFaker::AddressNL.street_address}
    sequence(:district) {|n| "district#{n}"}
    phone     {FFaker::PhoneNumber.short_phone_number}
  end
end
