module Gesmew
  module Api
    module V1
      module Inspections
        class EstablishmentsController < Gesmew::Api::BaseController

          def create
            authorize! :create, Gesmew::Establishment
            establishment = Gesmew::Establishment.find(params[:establishment][:establishment_id])
            if inspection.update_attributes(establishment: establishment)
              respond_with(inspection, status: 201, template: 'gesmew/api/v1/inspections/show')
            else
              invalid_resource!(inspection)
            end
          end

          def destroy
            authorize! :destroy, inspection.establishment
            inspection.update_attributes(establishment:nil)
            render :nothing => true, :status => 204
          end
        end
      end
    end
  end
end
