module Gesmew
  module Api
    module V1
      class OrdersController < Gesmew::Api::BaseController
        skip_before_action :check_for_user_or_api_key, only: :apply_coupon_code
        skip_before_action :authenticate_user, only: :apply_coupon_code

        before_action :find_order, except: [:create, :mine, :current, :index, :update]

        # Dynamically defines our stores checkout steps to ensure we check authorization on each step.
        Inspection.checkout_steps.keys.each do |step|
          define_method step do
            find_order
            authorize! :update, @inspection, params[:token]
          end
        end

        def cancel
          authorize! :update, @inspection, params[:token]
          @inspection.cancel!
          respond_with(@inspection, :default_template => :show)
        end

        def create
          authorize! :create, Inspection
          order_user = if @current_user_roles.include?('admin') && order_params[:user_id]
            Gesmew.user_class.find(order_params[:user_id])
          else
            current_api_user
          end

          import_params = if @current_user_roles.include?("admin")
            params[:inspection].present? ? params[:inspection].permit! : {}
          else
            order_params
          end

          @inspection = Gesmew::Core::Importer::Inspection.import(order_user, import_params)
          respond_with(@inspection, default_template: :show, status: 201)
        end

        def empty
          authorize! :update, @inspection, order_token
          @inspection.empty!
          render text: nil, status: 204
        end

        def index
          authorize! :index, Inspection
          @inspections = Inspection.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@inspections)
        end

        def show
          authorize! :show, @inspection, order_token
          respond_with(@inspection)
        end

        def update
          find_order(true)
          authorize! :update, @inspection, order_token

          if @inspection.contents.update_cart(order_params)
            user_id = params[:inspection][:user_id]
            if current_api_user.has_gesmew_role?('admin') && user_id
              @inspection.associate_user!(Gesmew.user_class.find(user_id))
            end
            respond_with(@inspection, default_template: :show)
          else
            invalid_resource!(@inspection)
          end
        end

        def current
          @inspection = find_current_order
          if @inspection
            respond_with(@inspection, default_template: :show, locals: { root_object: @inspection })
          else
            head :no_content
          end
        end

        def mine
          if current_api_user.persisted?
            @inspections = current_api_user.inspections.reverse_chronological.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          else
            render "gesmew/api/errors/unauthorized", status: :unauthorized
          end
        end

        def apply_coupon_code
          find_order
          authorize! :update, @inspection, order_token
          @inspection.coupon_code = params[:coupon_code]
          @handler = PromotionHandler::Coupon.new(@inspection).apply
          status = @handler.successful? ? 200 : 422
          render "gesmew/api/v1/promotions/handler", :status => status
        end

        private
          def order_params
            if params[:inspection]
              normalize_params
              params.require(:inspection).permit(permitted_order_attributes)
            else
              {}
            end
          end

          def normalize_params
            params[:inspection][:payments_attributes] = params[:inspection].delete(:payments) if params[:inspection][:payments]
            params[:inspection][:shipments_attributes] = params[:inspection].delete(:shipments) if params[:inspection][:shipments]
            params[:inspection][:line_items_attributes] = params[:inspection].delete(:line_items) if params[:inspection][:line_items]
            params[:inspection][:ship_address_attributes] = params[:inspection].delete(:ship_address) if params[:inspection][:ship_address]
            params[:inspection][:bill_address_attributes] = params[:inspection].delete(:bill_address) if params[:inspection][:bill_address]
          end

          def find_order(lock = false)
            @inspection = Gesmew::Inspection.lock(lock).friendly.find(params[:id])
          end

          def find_current_order
            current_api_user ? current_api_user.inspections.incomplete.inspection(:created_at).last : nil
          end

          def order_id
            super || params[:id]
          end
      end
    end
  end
end
