module Gesmew
  class ContactInformation < Gesmew::Base
    self.table_name = 'gesmew_contact_information'

    has_one  :user
    has_many :establishments
  end
end