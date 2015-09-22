module Gesmew
  class Establishment < Gesmew::Base
    has_many   :inspections
    belongs_to :establishment_type
    belongs_to :contact_information

    validates :name, presence: true, uniqueness: true
    validates :establishment_type, presence: true
    validates :contact_information, presence: true
  end
end
