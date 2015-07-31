module Gesmew
  class Asset < Gesmew::Base
    belongs_to :viewable, polymorphic: true, touch: true
    acts_as_list scope: [:viewable_id, :viewable_type]
  end
end
