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

    scope :text_search, ->(query) {search(
      name_start: query
    ).result}

    def owner_fullname
      contact_information.fullname
    end

    def address
      contact_information.address
    end

    def country
      contact_information.country
    end

    def phone_number
      contact_information.phone_number
    end
  end
end
