module Gesmew
  module Api
    module V1
      class RubricsController < Gesmew::Api::BaseController

        def update
          authorize! :update, Gesmew::InspectionScope
          @rubric = Gesmew::Rubric.find_by(context_id: params[:id])
          data = {
            id:params[:id],
            criteria: params[:criteria]
          }
          if @rubric.update_criteria(data)
            respond_with(@rubric, status: 200, template: 'gesmew/api/v1/rubrics/show')
          else
            invalid_resource!(@rubric)
          end

        end

        def show
          @rubric = Gesmew::Rubric.find_by(context_id: params[:id])
          respond_with(@rubric, status: 200, template: 'gesmew/api/v1/rubrics/show')
        end
      end
    end
  end
end
