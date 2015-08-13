module Gesmew
  module Api
    module V1
      class ShipmentsController < Gesmew::Api::BaseController

        before_action :find_and_update_shipment, only: [:ship, :ready, :add, :remove]
        before_action :load_transfer_params, only: [:transfer_to_location, :transfer_to_shipment]

        def mine
          if current_api_user.persisted?
            @shipments = Gesmew::Shipment
              .reverse_chronological
              .joins(:inspection)
              .where(gesmew_orders: {user_id: current_api_user.id})
              .includes(mine_includes)
              .ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          else
            render "gesmew/api/errors/unauthorized", status: :unauthorized
          end
        end

        def create
          @inspection = Gesmew::Inspection.find_by!(number: params.fetch(:shipment).fetch(:order_id))
          authorize! :read, @inspection
          authorize! :create, Shipment
          quantity = params[:quantity].to_i
          @shipment = @inspection.shipments.create(stock_location_id: params.fetch(:stock_location_id))
          @inspection.contents.add(variant, quantity, {shipment: @shipment})

          @shipment.save!

          respond_with(@shipment.reload, default_template: :show)
        end

        def update
          @shipment = Gesmew::Shipment.accessible_by(current_ability, :update).readonly(false).friendly.find(params[:id])
          @shipment.update_attributes_and_order(shipment_params)

          respond_with(@shipment.reload, default_template: :show)
        end

        def ready
          unless @shipment.ready?
            if @shipment.can_ready?
              @shipment.ready!
            else
              render 'gesmew/api/v1/shipments/cannot_ready_shipment', status: 422 and return
            end
          end
          respond_with(@shipment, default_template: :show)
        end

        def ship
          unless @shipment.shipped?
            @shipment.ship!
          end
          respond_with(@shipment, default_template: :show)
        end

        def add
          quantity = params[:quantity].to_i

          @shipment.inspection.contents.add(variant, quantity, {shipment: @shipment})

          respond_with(@shipment, default_template: :show)
        end

        def remove
          quantity = params[:quantity].to_i

          @shipment.inspection.contents.remove(variant, quantity, {shipment: @shipment})
          @shipment.reload if @shipment.persisted?
          respond_with(@shipment, default_template: :show)
        end

        def transfer_to_location
          @stock_location = Gesmew::StockLocation.find(params[:stock_location_id])

          unless @quantity > 0
            unprocessable_entity('ArgumentError')
            return
          end

          @original_shipment.transfer_to_location(@variant, @quantity, @stock_location)
          render json: {success: true, message: Gesmew.t(:shipment_transfer_success)}, status: 201
        end

        def transfer_to_shipment
          @target_shipment  = Gesmew::Shipment.friendly.find(params[:target_shipment_number])

          if @quantity < 0 || @target_shipment == @original_shipment
            unprocessable_entity('ArgumentError')
            return
          end

          @original_shipment.transfer_to_shipment(@variant, @quantity, @target_shipment)
          render json: {success: true, message: Gesmew.t(:shipment_transfer_success)}, status: 201
        end

        private

        def load_transfer_params
          @original_shipment         = Gesmew::Shipment.friendly.find(params[:original_shipment_number])
          @variant                   = Gesmew::Variant.find(params[:variant_id])
          @quantity                  = params[:quantity].to_i
          authorize! :read, @original_shipment
          authorize! :create, Shipment
        end

        def find_and_update_shipment
          @shipment = Gesmew::Shipment.accessible_by(current_ability, :update).readonly(false).friendly.find(params[:id])
          @shipment.update_attributes(shipment_params)
          @shipment.reload
        end

        def shipment_params
          if params[:shipment] && !params[:shipment].empty?
            params.require(:shipment).permit(permitted_shipment_attributes)
          else
            {}
          end
        end

        def variant
          @variant ||= Gesmew::Variant.unscoped.find(params.fetch(:variant_id))
        end

        def mine_includes
          {
            inspection: {
              bill_address: {
                state: {},
                country: {},
              },
              ship_address: {
                state: {},
                country: {},
              },
              adjustments: {},
              payments: {
                inspection: {},
                payment_method: {},
              },
            },
            inventory_units: {
              line_item: {
                establishment: {},
                variant: {},
              },
              variant: {
                establishment: {},
                default_price: {},
                option_values: {
                  option_type: {},
                },
              },
            },
          }
        end
      end
    end
  end
end
