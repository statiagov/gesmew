module Gesmew
  module Admin
    class GeneralSettingsController < Gesmew::Admin::BaseController
      include Gesmew::Backend::Callbacks


      def edit
        @preferences_security = []
      end

      def update
        params.each do |name, value|
          next unless Gesmew::Config.has_preference? name
          Gesmew::Config[name] = value
        end

        flash[:success] = Gesmew.t(:successfully_updated, resource: Gesmew.t(:general_settings))
        redirect_to edit_admin_general_settings_path
      end

      def clear_cache
        Rails.cache.clear
        invoke_callbacks(:clear_cache, :after)
        head :no_content
      end
    end
  end
end
