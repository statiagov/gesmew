FactoryGirl.define do
  factory :image, class: Gesmew::Image do
    attachment { File.new(Gesmew::Core::Engine.root + "spec/fixtures" + 'thinking-cat.jpg') }
  end
end
