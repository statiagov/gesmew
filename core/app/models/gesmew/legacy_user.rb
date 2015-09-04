module Gesmew
  class LegacyUser < Gesmew::Base

    self.table_name = 'gesmew_users'

    belongs_to :contact_information

    has_many :inspection_users, class_name: Gesmew::InspectionUser, :foreign_key => :user_id
    has_many :inspections, -> {distinct}, class_name: Gesmew::Inspection, :through => :inspection_users

    # has_many :role_users, class_name: Gesmew::RoleUser, foreign_key: :user_id
    # has_many :gesmew_roles, through: :role_users, class_name: Gesmew::Role, source: :role

    def has_gesmew_role?(role)
      true
    end

    def first_name
      contact_information.firstname
    end

    def last_name
      contact_information.lastname
    end

    def full_name
      contact_information.fullname
    end

    attr_accessor :password
    attr_accessor :password_confirmation

    private

  end
end
