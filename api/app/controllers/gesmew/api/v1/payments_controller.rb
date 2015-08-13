module Gesmew
  module Api
    module V1
      class PaymentsController < Gesmew::Api::BaseController

        before_action :find_order
        before_action :find_payment, only: [:update, :show, :authorize, :purchase, :capture, :void]

        def index
          @payments = @inspection.payments.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@payments)
        end

        def new
          @payment_methods = Gesmew::PaymentMethod.available
          respond_with(@payment_methods)
        end

        def create
          @payment = @inspection.payments.build(payment_params)
          if @payment.save
            respond_with(@payment, status: 201, default_template: :show)
          else
            invalid_resource!(@payment)
          end
        end

        def update
          authorize! params[:action], @payment
          if !@payment.editable?
            render 'update_forbidden', status: 403
          elsif @payment.update_attributes(payment_params)
            respond_with(@payment, default_template: :show)
          else
            invalid_resource!(@payment)
          end
        end

        def show
          respond_with(@payment)
        end

        def authorize
          perform_payment_action(:authorize)
        end

        def capture
          perform_payment_action(:capture)
        end

        def purchase
          perform_payment_action(:purchase)
        end

        def void
          perform_payment_action(:void_transaction)
        end

        private

          def find_order
            @inspection = Gesmew::Inspection.friendly.find(order_id)
            authorize! :read, @inspection, order_token
          end

          def find_payment
            @payment = @inspection.payments.friendly.find(params[:id])
          end

          def perform_payment_action(action, *args)
            authorize! action, Payment
            @payment.send("#{action}!", *args)
            respond_with(@payment, default_template: :show)
          end

          def payment_params
            params.require(:payment).permit(permitted_payment_attributes)
          end
      end
    end
  end
end
