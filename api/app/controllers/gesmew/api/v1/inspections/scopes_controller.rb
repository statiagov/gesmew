module Gesmew
  module Api
    module V1
      module Inspections
        class ScopesController < Gesmew::Api::BaseController

          def create
            authorize! :create, Gesmew::InspectionScope
            scope = Gesmew::InspectionScope.find(params[:scope_id])
            if inspection.update_attributes(scope: scope)
              inspection.rubric.associate_with(inspection, scope)
              respond_with(inspection, status: 201, template: 'gesmew/api/v1/inspections/show')
            else
              invalid_resource!(inspection)
            end
          end

          def destroy
            authorize! :destroy, inspection
            inspection.rubric.dissociate_with(inspection, inspection.scope)
            inspection.update_attributes(scope:nil)
            render :nothing => true, :status => 204
          end
        end
      end
    end
  end
end
