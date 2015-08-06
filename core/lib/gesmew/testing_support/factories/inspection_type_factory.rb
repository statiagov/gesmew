FactoryGirl.define do
  factory :inspection_type do
    sequence(:name)        {|n| "Type #{n}" }
    sequence(:description) {|n| "Description of type #{n}"}
  end
end