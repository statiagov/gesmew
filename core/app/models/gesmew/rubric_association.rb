module Gesmew
  class RubricAssociation < ActiveRecord::Base
    belongs_to :rubric
    belongs_to :association_object, polymorphic: true, foreign_type: :association_type, foreign_key: :association_id
    validates_inclusion_of :association_type, allow_nil: true, in: ['Gesmew::Inspection']
    belongs_to :context, polymorphic: true
    validates_inclusion_of :context_type, allow_nil:true, in:['Gesmew::InspectionScope']
    has_many :rubric_assessments, dependent: :nullify

    before_save :update_criteria_count
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

    def update_criteria_count
      self.association_object.update_attribute(:criteria_count, self.rubric.criteria_count)
    end

    def update_values
      self.title ||= self.association_object.number
    end

    def assess(opts={})
      association = self
      ratings = []
      criterion_met_count = nil
      replace_ratings = false
      params = opts[:assessment]
      self.rubric.criteria_object.each do |criterion|
        if opts[:initial].present?
          data = {criterion_met:false}
        else
          data = params["criterion_#{criterion.id}".to_sym]
        end
        rating = {}
        if data
          replace_ratings = true
          rating[:id] = criterion[:id]
          rating[:name] = criterion[:name]
          rating[:description] = criterion[:description]
          rating[:criterion_met] = data[:criterion_met]
          criterion_met_count ||= 0
          criterion_met_count += 1 if rating[:criterion_met] == true
          ratings << rating
        end
      end
      assessment = association.rubric_assessments.where(assessor: opts[:assessor], artifact:opts[:artifact], rubric: self.rubric)
      if assessment.empty? then assessment = nil end
      assessment ||= association.rubric_assessments.build(assessor: opts[:assessor], artifact:opts[:artifact], rubric: self.rubric)
      assessment.criterion_met_count = criterion_met_count if replace_ratings
      assessment.data = ratings if replace_ratings
      assessment.tap(&:save)
    end

    def assessment(opts={})
      return nil unless opts.present?
      self.rubric_assessments.where(assessor: opts[:assessor], artifact:opts[:artifact], rubric: self.rubric).first
    end
  end
end
