FactoryGirl.define do
  factory :contact_information, class: Gesmew::ContactInformation do
    email { generate(:random_email) }
    firstname {FFaker::Name.first_name}
    lastname  {FFaker::Name.last_name}
    address   {FFaker::AddressNL.street_address}
    sequence(:district) {|n| "District#{n}"}
    phone_number {FFaker::PhoneNumber.short_phone_number}
  end
end
