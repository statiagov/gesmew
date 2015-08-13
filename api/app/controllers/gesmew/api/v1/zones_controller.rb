module Gesmew
  module Api
    module V1
      class ZonesController < Gesmew::Api::BaseController

        def create
          authorize! :create, Zone
          @zone = Zone.new(map_nested_attributes_keys(Gesmew::Zone, zone_params))
          if @zone.save
            respond_with(@zone, :status => 201, :default_template => :show)
          else
            invalid_resource!(@zone)
          end
        end

        def destroy
          authorize! :destroy, zone
          zone.destroy
          respond_with(zone, :status => 204)
        end

        def index
          @zones = Zone.accessible_by(current_ability, :read).inspection('name ASC').ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@zones)
        end

        def show
          respond_with(zone)
        end

        def update
          authorize! :update, zone
          if zone.update_attributes(map_nested_attributes_keys(Gesmew::Zone, zone_params))
            respond_with(zone, :status => 200, :default_template => :show)
          else
            invalid_resource!(zone)
          end
        end

        private
        def zone_params
          params.require(:zone).permit!
        end

        def zone
          @zone ||= Gesmew::Zone.accessible_by(current_ability, :read).find(params[:id])
        end
      end
    end
  end
end
