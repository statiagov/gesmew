module Gesmew
  class Inspection < Gesmew::Base

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged

    include Gesmew::Inspection::Flow
    include Gesmew::Core::NumberGenerator.new(prefix:'N')

    belongs_to :establishment
    belongs_to :scope, polymorphic: true
    has_many   :state_changes, as: :stateful, dependent: :destroy
    validates_inclusion_of :scope_type, allow_nil:true, in:['Gesmew::InspectionScope']

    has_many  :inspection_users, class_name: Gesmew::InspectionUser, :foreign_key => :inspection_id

    if Gesmew.user_class
      has_many   :inspectors, -> {uniq}, class_name: Gesmew.user_class.to_s, :through => :inspection_users, :source => :user
    else
      has_many   :inspectors, -> {uniq}, :through => :inspection_users, source: :user
    end

    def score_total
      Random.rand(10) + 1
    end

    def completed?
      completed_at.present?
    end

    def rubric
      scope.rubric
    end

    def can_cancel?
      return true unless state?(:pending)
    end

    def add_inspector(*inspectors)
      inspectors.each do |inspector|
        self.inspectors << inspector
      end
      self.tap(&:save)
    end

    def remove_inspector(*inspectors)
      inspectors.each do |inspector|
        self.inspectors.delete(inspector)
      end
      save
    end

    inspection_flow do
      go_to_state :processed
      go_to_state :grading_and_commenting
      go_to_state :completed
    end

    def ensure_establishment_present
      unless establishment.present?
        errors.add(:base, Gesmew.t(:there_is_no_establishment_for_this_inspection)) and return false
      end
    end

    def initial_assessment(user_id)
      user = gesmew_user(user_id)
      if user.is_part_of_inspection?(self.number)
        get_rubric_association.assess({assessor:user, artifact:self},true)
      end
    end

    def ensure_at_least_two_inspectors
      unless inspectors.size > 1
        errors.add(:base, Gesmew.t(:there_should_be_two_or_more_inspectors)) and return false
      end
    end

    def ensure_scope_present
      unless scope.present?
        errors.add(:base, Gesmew.t(:there_is_no_scope_for_this_inspection)) and return false
      end
    end

    def get_rubric_association
      scope.rubric.rubric_associations.where(association_id:self.id).first
    end

    private

    def gesmew_user(id)
      Gesmew.user_class.find(id)
    end
  end
end
