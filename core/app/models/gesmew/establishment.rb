module Gesmew
  class Establishment < Gesmew::Base

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged

    has_many   :inspections
    belongs_to :establishment_type
    belongs_to :contact_information

    validates :name, presence: true, uniqueness: true
    validates :establishment_type, presence: true
    validates :contact_information, presence: true


    delegate :firstname,    to: :contact_information, allow_nil: true, prefix: false
    delegate :lastname,     to: :contact_information, allow_nil: true, prefix: false
    delegate :fullname,     to: :contact_information, allow_nil: true, prefix: false
    delegate :phone_number, to: :contact_information, allow_nil: true, prefix: false
    delegate :address,      to: :contact_information, allow_nil: true, prefix: false
    delegate :country,      to: :contact_information, allow_nil: true, prefix: false
    delegate :email,        to: :contact_information, allow_nil: true, prefix: false

    scope :text_search, ->(query) {search(
      name_start: query
    ).result}

  end
end
