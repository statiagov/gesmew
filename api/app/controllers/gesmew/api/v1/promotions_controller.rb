module Gesmew
  module Api
    module V1
      class PromotionsController < Gesmew::Api::BaseController
        before_filter :requires_admin
        before_filter :load_promotion

        def show
          if @promotion
            respond_with(@promotion, default_template: :show)
          else
            raise ActiveRecord::RecordNotFound
          end
        end

        private
          def requires_admin
            return if @current_user_roles.include?("admin")
            unauthorized and return
          end

          def load_promotion
            @promotion = Gesmew::Promotion.find_by_id(params[:id]) || Gesmew::Promotion.with_coupon_code(params[:id])
          end
      end
    end
  end
end
