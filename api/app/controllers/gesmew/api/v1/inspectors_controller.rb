module Gesmew
  module Api
    module V1
      class InspectorsController < Gesmew::Api::BaseController
        class_attribute :inspector_options

        self.inspector_options = []

        def create
          inspector = Gesmew.user_class.find(params[:inspector][:inspector_id])
          @inspection = inspection.add_inspector(inspector)

          if @inspection.errors.empty?
            respond_with(@inspection, status: 201, template: 'gesmew/api/v1/inspections/show')
          else
            invalid_resource!(@inspection)
          end
        end

        def destroy
          inspector = Gesmew.user_class.find(params[:id])
          inspection.remove_inspector(inspector)
          render :nothing => true, :status => 204
        end          
      end
    end
  end
end
