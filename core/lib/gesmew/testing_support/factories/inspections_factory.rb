FactoryGirl.define do
  factory :inspection, class: Gesmew::Inspection do
    establishment
    completed_at                   {nil}
  end
end
