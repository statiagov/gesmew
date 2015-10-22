module Gesmew
  module Admin
    class SearchController < Gesmew::Admin::BaseController
      respond_to :json
      layout false

      before_action :check_json_authenticity, only: :index

      # TODO: Clean this UP urgently, add extra search as a scope on the model
      def users
        if params[:ids]
          @users = Gesmew.user_class.where(id: params[:ids].split(',').flatten)
        else
          exclude_ids = auto_complete_ids_to_exclude(params[:object])
          @users = Gesmew.user_class.text_search(params[:q]).search(id_not_in:exclude_ids).result.limit(10)
        end
      end

      def establishments
        if params[:ids]
          @establishments = Gesmew::Establishment.where(id: params[:ids].split(",").flatten)
        else
          @establishments = Gesmew::Establishment.text_search(params[:q])
        end
      end

      def inspection_scopes
        if params[:ids]
          @inspection_scopes = Gesmew::InspectionScope.where(id: params[:ids].slpit(",").flatten)
        else
          @inspection_scopes = Gesmew::InspectionScope.text_search(params[:q])
        end
      end
    end
  end
end
