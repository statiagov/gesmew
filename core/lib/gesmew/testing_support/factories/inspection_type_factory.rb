FactoryGirl.define do
  factory :inspection_type, class: Gesmew::InspectionType do
    sequence(:name)        {|n| "Type #{n}" }
    description "Some description"
  end
end
