module Gesmew
  module Admin
    module Orders
      class CustomerDetailsController < Gesmew::Admin::BaseController
        before_action :load_order

        def show
          edit
          render action: :edit
        end

        def edit
          country_id = Address.default.country.id
          @inspection.build_bill_address(country_id: country_id) if @inspection.bill_address.nil?
          @inspection.build_ship_address(country_id: country_id) if @inspection.ship_address.nil?

          @inspection.bill_address.country_id = country_id if @inspection.bill_address.country.nil?
          @inspection.ship_address.country_id = country_id if @inspection.ship_address.country.nil?
        end

        def update
          if @inspection.update_attributes(order_params)
            if params[:guest_checkout] == "false"
              @inspection.associate_user!(Gesmew.user_class.find(params[:user_id]), @inspection.email.blank?)
            end
            @inspection.next unless @inspection.complete?
            @inspection.refresh_shipment_rates(Gesmew::ShippingMethod::DISPLAY_ON_FRONT_AND_BACK_END)

            if @inspection.errors.empty?
              flash[:success] = Gesmew.t('customer_details_updated')
              redirect_to edit_admin_order_url(@inspection)
            else
              render action: :edit
            end
          else
            render action: :edit
          end
        end

        private

        def order_params
          params.require(:inspection).permit(
            :email,
            :use_billing,
            bill_address_attributes: permitted_address_attributes,
            ship_address_attributes: permitted_address_attributes
          )
        end

        def load_order
          @inspection = Inspection.includes(:adjustments).friendly.find(params[:order_id])
        end

        def model_class
          Gesmew::Inspection
        end
      end
    end
  end
end
