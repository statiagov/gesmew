module Gesmew
  module Admin
    module ImagesHelper
      def options_text_for(image)
        if image.viewable.is_a?(Gesmew::Variant)
          if image.viewable.is_master?
            Gesmew.t(:all)
          else
            image.viewable.sku_and_options_text
          end
        else
          Gesmew.t(:all)
        end
      end
    end
  end
end

