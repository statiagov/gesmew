module Gesmew
  module Admin
    class EstablishmentTypesController < ResourceController
      def show
        if request.xhr?
          render :layout => false
        else
          redirect_to admin_establishment_types_path
        end
      end

      def available
        @establishment_types = EstablishmentType.order('name asc')
        respond_with(@establishment_types) do |format|
          format.html { render :layout => !request.xhr? }
          format.js
        end
      end

      def select
        @establishment_type ||= EstablishmentType.find(params[:id])
      end
    end
  end
end
