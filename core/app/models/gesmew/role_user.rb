module Gesmew
  class RoleUser < Gesmew::Base
    belongs_to :role, class_name: 'Gesmew::Role'
    belongs_to :user, class_name: Gesmew.user_class.to_s
  end
end
