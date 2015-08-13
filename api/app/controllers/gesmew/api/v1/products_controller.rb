module Gesmew
  module Api
    module V1
      class ProductsController < Gesmew::Api::BaseController

        def index
          if params[:ids]
            @establishments = product_scope.where(id: params[:ids].split(",").flatten)
          else
            @establishments = product_scope.ransack(params[:q]).result
          end

          @establishments = @establishments.distinct.page(params[:page]).per(params[:per_page])
          expires_in 15.minutes, :public => true
          headers['Surrogate-Control'] = "max-age=#{15.minutes}"
          respond_with(@establishments)
        end

        def show
          @establishment = find_product(params[:id])
          expires_in 15.minutes, :public => true
          headers['Surrogate-Control'] = "max-age=#{15.minutes}"
          headers['Surrogate-Key'] = "product_id=1"
          respond_with(@establishment)
        end

        # Takes besides the establishments attributes either an array of variants or
        # an array of option types.
        #
        # By submitting an array of variants the option types will be created
        # using the *name* key in options hash. e.g
        #
        #   establishment: {
        #     ...
        #     variants: {
        #       price: 19.99,
        #       sku: "hey_you",
        #       options: [
        #         { name: "size", value: "small" },
        #         { name: "color", value: "black" }
        #       ]
        #     }
        #   }
        #
        # Or just pass in the option types hash:
        #
        #   establishment: {
        #     ...
        #     option_types: ['size', 'color']
        #   }
        #
        # By passing the shipping category name you can fetch or create that
        # shipping category on the fly. e.g.
        #
        #   establishment: {
        #     ...
        #     shipping_category: "Free Shipping Items"
        #   }
        #
        def create
          authorize! :create, Establishment
          params[:establishment][:available_on] ||= Time.now
          set_up_shipping_category

          options = { variants_attrs: variants_params, options_attrs: option_types_params }
          @establishment = Core::Importer::Establishment.new(nil, product_params, options).create

          if @establishment.persisted?
            respond_with(@establishment, :status => 201, :default_template => :show)
          else
            invalid_resource!(@establishment)
          end
        end

        def update
          @establishment = find_product(params[:id])
          authorize! :update, @establishment

          options = { variants_attrs: variants_params, options_attrs: option_types_params }
          @establishment = Core::Importer::Establishment.new(@establishment, product_params, options).update

          if @establishment.errors.empty?
            respond_with(@establishment.reload, :status => 200, :default_template => :show)
          else
            invalid_resource!(@establishment)
          end
        end

        def destroy
          @establishment = find_product(params[:id])
          authorize! :destroy, @establishment
          @establishment.destroy
          respond_with(@establishment, :status => 204)
        end

        private
          def product_params
            params.require(:establishment).permit(permitted_product_attributes)
          end

          def variants_params
            variants_key = if params[:establishment].has_key? :variants
              :variants
            else
              :variants_attributes
            end

            params.require(:establishment).permit(
              variants_key => [permitted_variant_attributes, :id],
            ).delete(variants_key) || []
          end

          def option_types_params
            params[:establishment].fetch(:option_types, [])
          end

          def set_up_shipping_category
            if shipping_category = params[:establishment].delete(:shipping_category)
              id = ShippingCategory.find_or_create_by(name: shipping_category).id
              params[:establishment][:shipping_category_id] = id
            end
          end
      end
    end
  end
end
