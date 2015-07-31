FactoryGirl.define do
  factory :role, class: Gesmew::Role do
    sequence(:name) { |n| "Role ##{n}" }

    factory :admin_role do
      name 'admin'
    end
  end
end
