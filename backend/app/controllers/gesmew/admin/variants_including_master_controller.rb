module Gesmew
  module Admin
    class VariantsIncludingMasterController < VariantsController
      belongs_to "gesmew/product", find_by: :slug

      def model_class
        Gesmew::Variant
      end

      def object_name
        "variant"
      end

    end
  end
end
