module Gesmew
  module Admin
    class OptionValuesController < Gesmew::Admin::BaseController
      def destroy
        option_value = Gesmew::OptionValue.find(params[:id])
        option_value.destroy
        render :text => nil
      end
    end
  end
end
