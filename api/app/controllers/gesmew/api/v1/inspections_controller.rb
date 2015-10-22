module Gesmew
  module Api
    module V1
      class InspectionsController < Gesmew::Api::BaseController

        before_action :find_inspection, except: [:create, :mine, :current, :index, :update]

        # Dynamically defines our inspection flow steps to ensure we check authorization on each step.
        Inspection.inspection_steps.keys.each do |step|
          define_method step do
            find_inspection
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
          authorize! :show, @inspection
          respond_with(@inspection)
        end

        def update
          find_inspection(true)
          authorize! :update, @inspection

          if @inspection.update(inspection_params)
            respond_with(@inspection, default_template: :show)
          else
            invalid_resource!(@inspection)
          end
        end

        def current
          @inspection = find_current_inspection
          if @inspection
            respond_with(@inspection, default_template: :show, locals: { root_object: @inspection })
          else
            head :no_content
          end
        end

        def advance
          find_inspection(true)
          authorize! :update, @inspection
          if @inspection.next
            respond_with(@inspection, default_template: :show)
          else
            render text: nil, status: 409
          end
        end

        # def mine
        #   if current_api_user.persisted?
        #     @inspections = current_api_user.inspections.reverse_chronological.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        #   else
        #     render "gesmew/api/errors/unauthorized", status: :unauthorized
        #   end
        # end

        private
          def inspection_params
            if params[:inspection]
              params.require(:inspection).permit(permitted_inspection_attributes)
            else
              {}
            end
          end

          def find_inspection(lock = false)
            @inspection = Gesmew::Inspection.lock(lock).friendly.find(params[:id])
          end

          def inspection_id
            super || params[:id]
          end
      end
    end
  end
end
