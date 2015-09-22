module Gesmew
  module Api
    module V1
      class EstablishmentsController < Gesmew::Api::BaseController

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

        def create
          authorize! :create, Gesmew::Establishment
          if params[:establishment][:establishment_id].present?
            establishment = Gesmew::Establishment.find(params[:establishment][:establishment_id])
            if inspection.update_attributes(establishment: establishment)
              respond_with(inspection, status: 201, template: 'gesmew/api/v1/inspections/show')
            else
              invalid_resource!(inspection)
            end
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
          if params[:establishment][:establishment_id].present?
            Gesmew::Establishment.find(params[:params[:establishment][:establishment_id]])
          end
          authorize! :destroy, @establishment
          @establishment.destroy
          respond_with(@establishment, :status => 204)
        end
      end
    end
  end
end
