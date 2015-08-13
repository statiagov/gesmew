module Gesmew
  module Admin
    class StateChangesController < Gesmew::Admin::BaseController
      before_action :load_order, only: [:index]

      def index
        @state_changes = @inspection.state_changes.includes(:user)
      end

      private

      def load_order
        @inspection = Inspection.find_by_number!(params[:order_id])
        authorize! action, @inspection
      end
    end
  end
end
