module Gesmew
  module TestingSupport
    module UrlHelpers
      def gesmew
        Gesmew::Core::Engine.routes.url_helpers
      end
    end
  end
end
