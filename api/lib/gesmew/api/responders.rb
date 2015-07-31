require 'gesmew/api/responders/rabl_template'

module Gesmew
  module Api
    module Responders
      class AppResponder < ActionController::Responder
        include RablTemplate
      end
    end
  end
end
