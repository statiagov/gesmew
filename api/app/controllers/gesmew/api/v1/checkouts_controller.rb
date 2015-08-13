module Gesmew
  module Api
    module V1
      class CheckoutsController < Gesmew::Api::BaseController
        before_action :associate_user, only: :update

        include Gesmew::Core::ControllerHelpers::Auth
        include Gesmew::Core::ControllerHelpers::Inspection
        # This before_filter comes from Gesmew::Core::ControllerHelpers::Inspection
        skip_before_action :set_current_order

        def next
          load_order(true)
          authorize! :update, @inspection, order_token
          @inspection.next!
          respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/show', status: 200)
        rescue StateMachines::InvalidTransition
          respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/could_not_transition', status: 422)
        end

        def advance
          load_order(true)
          authorize! :update, @inspection, order_token
          while @inspection.next; end
          respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/show', status: 200)
        end

        def update
          load_order(true)
          authorize! :update, @inspection, order_token

          if @inspection.update_from_params(params, permitted_checkout_attributes, request.headers.env)
            if current_api_user.has_gesmew_role?('admin') && user_id.present?
              @inspection.associate_user!(Gesmew.user_class.find(user_id))
            end

            return if after_update_attributes

            if @inspection.completed? || @inspection.next
              state_callback(:after)
              respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/show')
            else
              respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/could_not_transition', status: 422)
            end
          else
            invalid_resource!(@inspection)
          end
        end

        private

        def user_id
          params[:inspection][:user_id] if params[:inspection]
        end

        def nested_params
          map_nested_attributes_keys Inspection, params[:inspection] || {}
        end

        # Should be overriden if you have areas of your checkout that don't match
        # up to a step within checkout_steps, such as a registration step
        def skip_state_validation?
          false
        end

        def load_order(lock = false)
          @inspection = Gesmew::Inspection.lock(lock).find_by!(number: params[:id])
          raise_insufficient_quantity and return if @inspection.insufficient_stock_lines.present?
          @inspection.state = params[:state] if params[:state]
          state_callback(:before)
        end

        def raise_insufficient_quantity
          respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/insufficient_quantity')
        end

        def state_callback(before_or_after = :before)
          method_name = :"#{before_or_after}_#{@inspection.state}"
          send(method_name) if respond_to?(method_name, true)
        end

        def after_update_attributes
          if nested_params && nested_params[:coupon_code].present?
            handler = PromotionHandler::Coupon.new(@inspection).apply

            if handler.error.present?
              @coupon_message = handler.error
              respond_with(@inspection, default_template: 'gesmew/api/v1/inspections/could_not_apply_coupon')
              return true
            end
          end
          false
        end

        def order_id
          super || params[:id]
        end
      end
    end
  end
end
