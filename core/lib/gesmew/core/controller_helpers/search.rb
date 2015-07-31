module Gesmew
  module Core
    module ControllerHelpers
      module Search
        def build_searcher(params)
          Gesmew::Config.searcher_class.new(params).tap do |searcher|
            searcher.current_user = try_gesmew_current_user
            searcher.current_currency = current_currency
          end
        end
      end
    end
  end
end
