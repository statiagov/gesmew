FactoryGirl.define do
  factory :rubric, class: Gesmew::Rubric do
    user
    sequence(:title) {|n| "Title #{n}"}
    context do
      create(:inspection_scope)
    end
  end
end
