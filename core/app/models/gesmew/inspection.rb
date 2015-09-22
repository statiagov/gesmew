module Gesmew
  class Inspection < Gesmew::Base

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged

    include Gesmew::Inspection::Flow
    include Gesmew::Core::NumberGenerator.new(prefix:'N')

    belongs_to :establishment
    belongs_to :inspection_type
    has_many   :state_changes, as: :stateful, dependent: :destroy

    has_many  :inspection_users, class_name: Gesmew::InspectionUser, :foreign_key => :inspection_id

    if Gesmew.user_class
      has_many   :inspectors, -> {uniq}, class_name: Gesmew.user_class.to_s, :through => :inspection_users, :source => :user
    else
      has_many   :inspectors, -> {uniq}, :through => :inspection_users, source: :user
    end

    def establishment
      super || Gesmew::NullEstablishment.new
    end

    def establishment_type
      establishment.establishment_type
    end

    def score_total
      Random.rand(10) + 1
    end

    def completed?
      completed_at.present?
    end

    def can_cancel?
      return false unless completed? and state != 'canceled'
    end

    def add_inspector(inspector)
      self.inspectors << inspector
      save
      self
    end

    def remove_inspector(inspector)
      self.inspectors.delete(inspector)
      save
    end

    def stringy_establishment
      establishment.class.name.demodulize.underscore
    end

    inspection_flow do
      go_to_state :processing
      go_to_state :grading_and_commenting
      go_to_state :completed
    end
  end
end
