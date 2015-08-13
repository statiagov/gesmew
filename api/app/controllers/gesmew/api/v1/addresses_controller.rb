module Gesmew
  module Api
    module V1
      class AddressesController < Gesmew::Api::BaseController
        before_action :find_order

        def show
          authorize! :read, @inspection, order_token
          @address = find_address
          respond_with(@address)
        end

        def update
          authorize! :update, @inspection, order_token
          @address = find_address

          if @address.update_attributes(address_params)
            respond_with(@address, :default_template => :show)
          else
            invalid_resource!(@address)
          end
        end

        private

        def address_params
          params.require(:address).permit(permitted_address_attributes)
        end

        def find_order
          @inspection = Gesmew::Inspection.find_by!(number: order_id)
        end

        def find_address
          if @inspection.bill_address_id == params[:id].to_i
            @inspection.bill_address
          elsif @inspection.ship_address_id == params[:id].to_i
            @inspection.ship_address
          else
            raise CanCan::AccessDenied
          end
        end
      end
    end
  end
end
