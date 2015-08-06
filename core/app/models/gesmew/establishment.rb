module Gesmew
  class Establishment < Gesmew::Base
    has_many   :inspections
    belongs_to :establishment_type
    belongs_to :contact_information
  end
end
