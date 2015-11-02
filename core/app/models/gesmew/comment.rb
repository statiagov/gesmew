module Gesmew
  class Comment < ActiveRecord::Base
    include ActsAsCommentable::Comment

    belongs_to :commentable, :polymorphic => true

    default_scope { order('created_at ASC') }

    belongs_to :user, class_name: Gesmew.user_class.to_s

    has_one :image, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: "Gesmew::Image"

    delegate :firstname, to: :user, allow_nil: true, prefix: true
    delegate :lastname,  to: :user, allow_nil: true, prefix: true
    delegate :fullname,  to: :user, allow_nil: true, prefix: true
    delegate :attachment, to: :image, allow_nil: true, prefix: false

  end
end
