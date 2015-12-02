module Gesmew
  class InspectionScope < ActiveRecord::Base
    has_one :rubric, as: :context
    has_many :inspections, as: :scope

    validates :name, :description, presence: true
    validates_presence_of :rubric, on: [:update]

    scope :text_search, ->(query) {search(
      name_cont: query
    ).result}

    delegate :rubric_associations, to: :rubric, allow_nil: true, prefix: false
  end
end
