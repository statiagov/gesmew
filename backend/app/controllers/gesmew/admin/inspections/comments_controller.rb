module Gesmew
  module Admin
    class Inspections::CommentsController < CommentsController
      before_action :set_commentable

      private

      def set_commentable
        @commentable = Gesmew::Inspection.friendly.find(params[:inspection_id])
      end
    end
  end
end
