module Gesmew
  class LegacyUser < Gesmew::Base

    self.table_name = 'gesmew_users'

    has_many :inspection_users, class_name: Gesmew::InspectionUser
    has_many :inspections, class_name: Gesmew::Inspection, foreign_key: :inspection_id, through: :inspection_users, source: :inspection

    def has_gesmew_role?(role)
      true
    end

    attr_accessor :password
    attr_accessor :password_confirmation

    private

  end
end
