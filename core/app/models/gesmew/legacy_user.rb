module Gesmew
  class LegacyUser < Gesmew::Base

    self.table_name = 'gesmew_users'

    # has_many :orders, foreign_key: :user_id

    def has_gesmew_role?(role)
      true
    end

    attr_accessor :password
    attr_accessor :password_confirmation

    private

  end
end
