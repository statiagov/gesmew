FactoryGirl.define do
  factory :establishment, class: Gesmew::Establishment do
    sequence(:name) {|n| "Establishment #{n}"}
    establishment_type
    contact_information
    workers {10}
  end
end
