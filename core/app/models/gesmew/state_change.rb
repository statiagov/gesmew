module Gesmew
  class StateChange < Gesmew::Base
    belongs_to :stateful, polymorphic: true
    belongs_to :user
  end
end
