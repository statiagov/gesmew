module Gesmew
  module Admin
    class InspectionScopesController < ResourceController
      after_action :create_rubric, only: [:create]

      def index
        respond_with(@collection)
      end

      protected

        def location_after_save
          gesmew.edit_admin_inspection_scope_path(@inspection_scope)
        end

        def collection
          return @collection if defined?(@collection)
          params[:q] = {} if params[:q].blank?

          @collection = super
          @search = @collection.ransack(params[:q])
          @collection = @search.result(distinct: true).
            page(params[:page]).
            per(params[:per_page]) || Gesmew::Config[:inspection_scopes_per_page]
          @collection
        end

        def create_rubric
          Gesmew::Rubric.create(context:@inspection_scope)
        end
    end
  end
end
