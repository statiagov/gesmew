module Gesmew
  class Inspection < Gesmew::Base

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged

    include Gesmew::Inspection::Flow
    include Gesmew::Core::NumberGenerator.new(prefix:'I')

    belongs_to :establishment
    has_many   :state_changes, as: :stateful, dependent: :destroy

    has_many  :inspection_users, class_name: Gesmew::InspectionUser

    if Gesmew.user_class
      has_many   :inspectors, as: :user, class_name: Gesmew.user_class.to_s, through: :inspection_users, source: :user
    else
      has_many   :inspectors, as: :user, through: :inspection_users, source: :user
    end


    inspection_flow do
      go_to_state :establishment
    end

  end
end
