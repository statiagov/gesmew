module Gesmew
  module Admin
    class EstablishmentsController < ResourceController

      def index
        respond_with(@collection)
      end

      def new
        @contact_information = Gesmew::ContactInformation.new
        @establishment = @contact_information.establishments.new
      end

      protected
        def collection
          return @collection if defined?(@collection)
          params[:q] = {} if params[:q].blank?

          @collection = super
          @search = @collection.ransack(params[:q])
          @collection = @search.result(distinct: true).
            page(params[:page]).
            per(params[:per_page]) || Gesmew::Config[:establishments_per_page]
          @collection
        end

        def find_resource
          Gesmew::Establishment.find_by(number: params[:id])
        end

    end
  end
end
