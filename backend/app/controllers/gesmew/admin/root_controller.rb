module Gesmew
  module Admin
    class RootController < Gesmew::Admin::BaseController

      skip_before_filter :authorize_admin

      def index
        redirect_to admin_root_redirect_path
      end

      protected

      def admin_root_redirect_path
        gesmew.admin_inspections_path
      end
    end
  end
end
