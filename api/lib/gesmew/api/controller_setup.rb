require 'gesmew/api/responders'

module Gesmew
  module Api
    module ControllerSetup
      def self.included(klass)
        klass.class_eval do
          include CanCan::ControllerAdditions
          include Gesmew::Core::ControllerHelpers::Auth

          prepend_view_path Rails.root + "app/views"
          append_view_path File.expand_path("../../../app/views", File.dirname(__FILE__))

          self.responder = Gesmew::Api::Responders::AppResponder
          respond_to :json
        end
      end
    end
  end
end
