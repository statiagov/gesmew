module Gesmew
  class Role < Gesmew::Base
    has_many :role_users, class_name: 'Gesmew::RoleUser'
    has_many :users, through: :role_users, class_name: Gesmew.user_class.to_s

    validates :name, presence: true
  end
end
