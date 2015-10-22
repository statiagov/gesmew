module Gesmew
  module Api
    module V1
      class RubricsController < BaseController

        def show
          @rubric = Gesmew::Rubric.find(params[:id])
        end
      end
    end
  end
end
