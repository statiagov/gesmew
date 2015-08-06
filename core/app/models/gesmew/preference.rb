class Gesmew::Preference < Gesmew::Base
  serialize :value
  validates :key, presence: true, uniqueness: true
end
