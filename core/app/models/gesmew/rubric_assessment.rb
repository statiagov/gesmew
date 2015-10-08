module Gesmew
  class RubricAssessment < ActiveRecord::Base
    belongs_to :rubric, class_name: Gesmew::Rubric
    belongs_to :rubric_association, class_name: Gesmew::RubricAssociation
    belongs_to :assessor, class_name: Gesmew.user_class
    belongs_to :artifact, polymorphic: true, touch:true
    validates_inclusion_of :artifact_type, allow_nil: true, in: ['Gesmew::Inspection']
    serialize_utf8_safe :data
  end
end
