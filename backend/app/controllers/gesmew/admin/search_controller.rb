module Gesmew
  module Admin
    class SearchController < Gesmew::Admin::BaseController
      respond_to :json
      layout false

      # http://gesmewcommerce.com/blog/2010/11/02/json-hijacking-vulnerability/
      before_action :check_json_authenticity, only: :index

      # TODO: Clean this up by moving searching out to user_class_extensions
      # And then JSON building with something like Active Model Serializers
      def users
        if params[:ids]
          @users = Gesmew.user_class.where(id: params[:ids].split(',').flatten)
        else
          @users = Gesmew.user_class.ransack({
            m: 'or',
            first_name_start: params[:q],
            last_name_start:  params[:q]
          }).result.limit(10)
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
