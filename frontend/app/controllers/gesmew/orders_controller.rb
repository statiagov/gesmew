module Gesmew
  class OrdersController < Gesmew::StoreController
    before_action :check_authorization
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'gesmew/products', 'gesmew/orders'

    respond_to :html

    before_action :assign_order_with_lock, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

    def show
      @order = Order.find_by_number!(params[:id])
    end

    def update
      if @order.contents.update_cart(order_params)
        respond_with(@order) do |format|
          format.html do
            if params.has_key?(:checkout)
              @order.next if @order.cart?
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to cart_path
            end
          end
        end
      else
        respond_with(@order)
      end
    end

    # Shows the current incomplete order from the session
    def edit
      @order = current_order || Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
      associate_user
    end

    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      order    = current_order(create_order_if_necessary: true)
      variant  = Gesmew::Variant.find(params[:variant_id])
      quantity = params[:quantity].to_i
      options  = params[:options] || {}

      # 2,147,483,647 is crazy. See issue #2695.
      if quantity.between?(1, 2_147_483_647)
        begin
          order.contents.add(variant, quantity, options)
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
      else
        error = Gesmew.t(:please_enter_reasonable_quantity)
      end

      if error
        flash[:error] = error
        redirect_back_or_default(gesmew.root_path)
      else
        respond_with(order) do |format|
          format.html { redirect_to cart_path }
        end
      end
    end

    def empty
      if @order = current_order
        @order.empty!
      end

      redirect_to gesmew.cart_path
    end

    def accurate_title
      if @order && @order.completed?
        Gesmew.t(:order_number, :number => @order.number)
      else
        Gesmew.t(:shopping_cart)
      end
    end

    def check_authorization
      order = Gesmew::Order.find_by_number(params[:id]) || current_order

      if order
        authorize! :edit, order, cookies.signed[:guest_token]
      else
        authorize! :create, Gesmew::Order
      end
    end

    private

      def order_params
        if params[:order]
          params[:order].permit(*permitted_order_attributes)
        else
          {}
        end
      end

      def assign_order_with_lock
        @order = current_order(lock: true)
        unless @order
          flash[:error] = Gesmew.t(:order_not_found)
          redirect_to root_path and return
        end
      end
  end
end
