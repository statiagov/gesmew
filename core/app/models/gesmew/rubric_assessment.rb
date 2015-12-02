module Gesmew
  class RubricAssessment < ActiveRecord::Base
    belongs_to :rubric, class_name: Gesmew::Rubric
    belongs_to :rubric_association, class_name: Gesmew::RubricAssociation
    belongs_to :assessor, class_name: Gesmew.user_class
    belongs_to :artifact, polymorphic: true, touch:true
    validates_inclusion_of :artifact_type, allow_nil: true, in: ['Gesmew::Inspection']
    serialize_utf8_safe :data

    # after_create :update_artifact_assessed, if: lambda { |assessment| assessment.artifact.present? }
    #
    # def update_artifact_assessed
    #   self.artifact.update_attribute(:assessed, true)
    # end

    def update_criteria(criteria)
      unless criteria.present?
        byebug
      end
    end
  end
end
