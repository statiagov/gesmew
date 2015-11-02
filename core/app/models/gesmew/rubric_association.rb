module Gesmew
  class RubricAssociation < ActiveRecord::Base
    belongs_to :rubric
    belongs_to :association_object, polymorphic: true, foreign_type: :association_type, foreign_key: :association_id
    validates_inclusion_of :association_type, allow_nil: true, in: ['Gesmew::Inspection']
    belongs_to :context, polymorphic: true
    validates_inclusion_of :context_type, allow_nil:true, in:['Gesmew::InspectionScope']
    has_many :rubric_assessments, dependent: :nullify

    before_save :update_inspection_points
    before_save :update_values

    ValidAssociationModels = {
      'Gesmew::Inspection' => Gesmew::Inspection
   }

    def self.get_association_object(params)
      return nil unless params
      a_id = params[:association_id]
      a_type =  params[:association_type]
      klass = ValidAssociationModels[a_type]
      return nil unless klass
      klass.where(id:a_id).first if a_id.present?
    end

    def update_inspection_points
      self.association_object.update_attribute(:points_possible, self.rubric.points_possible)
    end

    def update_values
      self.title ||= self.association_object.number
    end

    def assess(opts={}, initital=false)
      association = self
      ratings = []
      score = nil
      has_score = false
      replace_ratings = false
      params = opts[:assessment]
      self.rubric.criteria_object.each do |criterion|
        if initital
          data = {points:0}
        else
          data = params["criterion_#{criterion.id}".to_sym]
        end
        rating = {}
        if data
          replace_ratings = true
          has_score = (data[:points]).present?
          rating[:id] = criterion[:id]
          rating[:name] = criterion[:name]
          rating[:description] = criterion[:description]
          rating[:score] = [criterion.points, data[:score].to_f].min if has_score
          rating[:points] = criterion[:points]
          if has_score
            score ||= 0
            score += rating[:score]
          end
          ratings << rating
        end
      end
      assessment = association.rubric_assessments.where(assessor: opts[:assessor], artifact:opts[:artifact], rubric: self.rubric)
      if assessment.empty? then assessment = nil end
      assessment ||= association.rubric_assessments.build(assessor: opts[:assessor], artifact:opts[:artifact], rubric: self.rubric)
      assessment.score = score if replace_ratings
      assessment.data = ratings if replace_ratings
      assessment.tap(&:save)
    end

    def assessment(opts={})
      return nil unless opts.present?
      self.rubric_assessments.where(assessor: opts[:assessor], artifact:opts[:artifact], rubric: self.rubric).first
    end
  end
end
