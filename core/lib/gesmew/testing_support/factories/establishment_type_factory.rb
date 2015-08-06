FactoryGirl.define do
  factory :establishment_type, class: Gesmew::EstablishmentType do
    sequence(:name) {|n| "Type #{n}"}
    description {'Some random description'}
  end
end
