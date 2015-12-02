module Gesmew
  class Rubric < ActiveRecord::Base
    class Updater
      def initialize(params)
        @params = params
      end

      def update
        @rubric = Gesmew::Rubric.find_by(context_id: @params[:id])
        data = {
          id:@params[:id],
          criteria: @params[:criteria]
        }
        @rubric = @rubric.update_criteria(data)
        update_assessment_data
        @rubric
      end

      private

      def update_assessment_data
        if rubric_assessments.any?
          rubric_assessments.each do |assessment|
            assessment.transaction do
              new_assesment_data = transpose assessment.data, @rubric.data
              assessment.update(data:new_assesment_data)
            end
          end
        end
      end

      def transpose(assessment_data, rubric_data)
        criteria = []
        rubric_data.zip assessment_data do |rubric, assessment|
          criterion = {}
          criterion[:id] = rubric[:id]
          criterion[:description] = rubric[:description]
          criterion[:name] = rubric[:name]
          criterion[:criterion_met] = false
          criteria << criterion
        end
        criteria
      end

      def rubric_assessments
        inspection_complete_ids = Gesmew::Inspection.where(state:'completed').map(&:id)
        assessments = @rubric.rubric_associations.where.not(association_id: inspection_complete_ids).collect do |association|
          association.rubric_assessments.where.not(data: nil)
        end
        assessments.flatten
      end
    end
  end
end
