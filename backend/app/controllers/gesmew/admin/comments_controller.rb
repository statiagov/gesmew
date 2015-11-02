module Gesmew
  module Admin
    class CommentsController < BaseController
      def create
        @comment = @commentable.comments.new comment_params
        @comment.user = try_gesmew_current_user
        @comment.save
        if params[:comment][:attachment].present?
          @comment.image = Gesmew::Image.new(attachment:params[:comment][:attachment], viewable_id: @comment.id, viewable_type:'Gesmew::Comment')
        end
        if @comment.save
          redirect_to grade_and_comment_admin_inspection_path(@commentable)
        end
      end

      private
        def comment_params
          params.require(:comment).permit(:comment)
        end

        def attachment_params
          params.require(:comment).permit(:attachment, :viewable_type, :viewable_id)
        end
    end
  end
end
