module Gesmew
  class ContactInformation < Gesmew::Base
    self.table_name = 'gesmew_contact_information'

    before_save :add_fullname

    has_one  :user
    has_many :establishments

    private
      def add_fullname
        self[:fullname] = "#{firstname} #{lastname}"
      end
  end
end
