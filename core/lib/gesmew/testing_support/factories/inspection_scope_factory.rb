FactoryGirl.define  do
  factory :inspection_scope, class: Gesmew::InspectionScope do
    sequence(:name) {|n| "Scope #{n}"}
    sequence(:description) {|n| "Scope description#{n}"}
  end
end
