module Gesmew
  class InspectionUser < Gesmew::Base
    belongs_to :user, class_name: Gesmew.user_class.to_s
    belongs_to :inspection
  end
end
