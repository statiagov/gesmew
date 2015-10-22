module Gesmew
  module Api
    module V1
      module Inspections
        class AssessmentsController < Gesmew::Api::BaseController
          def index
            assessment = association.assess({
              artifact:inspection,
              assessor: current_api_user,
              assessment: params[:assessment]
            })
            byebug
          end

          private
           def association
             @association ||= Gesmew::RubricAssociation.find_by(params[:association])
           end
        end
      end
    end
  end
end
