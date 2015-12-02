module Gesmew
  class Rubric < ActiveRecord::Base
    belongs_to :user, class_name: Gesmew.user_class
    belongs_to :context, polymorphic: true
    has_many :rubric_associations, class_name: 'Gesmew::RubricAssociation', dependent: :destroy
    validates_inclusion_of :context_type, allow_nil:true, in:['Gesmew::InspectionScope']


    serialize_utf8_safe :data

    CriteriaData = Struct.new(:criteria, :criteria_count, :title)
    def generate_criteria(params)
      @used_ids = {}
      title = params[:title] || Gesmew.t(:context_rubric_name, name: context.name)
      criteria_count = 0
      criteria = []
      (params[:criteria] || {}).each_with_index do |criterion_data, idx|
        criterion = {}
        criterion[:name] = criterion_data[:name]
        criterion[:description] = (criterion_data[:description] || Gesmew.t(:no_desription))
        criterion[:required] = criterion_data[:required]
        criterion_data[:id].strip! if criterion_data[:id]
        criterion_data[:id] = nil if criterion_data[:id] && criterion_data[:id].empty?
        criterion[:id] = unique_item_id(criterion_data[:id])
        criteria_count += 1
        criteria[idx.to_i] = criterion
      end
      CriteriaData.new(criteria, criteria_count, title)
    end

    def criteria
      self.data
    end

    def associate_with(association, context, opts={})
      res =  self.rubric_associations.where(association_id: association, association_type: association.class.to_s).first
      return res if res
      ra = rubric_associations.build(association_object:association, context:context)
      ra.tap(&:save)
    end

    def dissociate_with(association, context, opts={})
      res =  self.rubric_associations.where(association_id: association, association_type: association.class.to_s).first
      self.rubric_associations.destroy(res)
    end

    def update_with_association(current_user, rubric_params, context, association_params)
      self.user ||= current_user
      self.update_criteria(rubric_params)
      Gesmew::RubricAssociation.generate(current_user, self, context, association_params)
    end

    def update_criteria(params)
      data = self.generate_criteria(params)
      self.data = data.criteria
      self.title = data.title
      self.criteria_count = data.criteria_count
      self.save
      self
    end

    def unique_item_id(id=nil)
      @used_ids ||= {}
      while !id || @used_ids[id]
        id = "#{self.id}_#{rand(10000)}"
      end
      @used_ids[id] = true
      id
    end

    def criteria_object
      Gesmew::OpenObject.process(self.data)
    end
  end
end
