module Gesmew
  module Admin
    module InventorySettingsHelper
      def show_not(true_or_false)
        true_or_false ? '' : Gesmew.t(:not)
      end
    end
  end
end
