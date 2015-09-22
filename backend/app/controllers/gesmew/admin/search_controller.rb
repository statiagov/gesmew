module Gesmew
  module Admin
    class SearchController < Gesmew::Admin::BaseController
      respond_to :json
      layout false

      before_action :check_json_authenticity, only: :index

      # TODO: Clean this UP urgently, association is hard coded!!!
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
          @establishments = Establishment.where(id: params[:ids].split(",").flatten)
        else
          @establishments = Establishment.ransack(params[:q]).result
        end

        @establishments = @establishments.distinct.page(params[:page]).per(params[:per_page])
        expires_in 15.minutes, public: true
        headers['Surrogate-Control'] = "max-age=#{15.minutes}"
      end
    end
  end
end
