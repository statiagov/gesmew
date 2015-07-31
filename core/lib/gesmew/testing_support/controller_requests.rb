# Use this module to easily test Gesmew actions within Gesmew components
# or inside your application to test routes for the mounted Gesmew engine.
#
# Inside your spec_helper.rb, include this module inside the RSpec.configure
# block by doing this:
#
#   require 'gesmew/testing_support/controller_requests'
#   RSpec.configure do |c|
#     c.include Gesmew::TestingSupport::ControllerRequests, :type => :controller
#   end
#
# Then, in your controller tests, you can access gesmew routes like this:
#
#   require 'spec_helper'
#
#   describe Gesmew::ProductsController do
#     it "can see all the products" do
#       gesmew_get :index
#     end
#   end
#
# Use gesmew_get, gesmew_post, gesmew_put or gesmew_delete to make requests
# to the Gesmew engine, and use regular get, post, put or delete to make
# requests to your application.
#
module Gesmew
  module TestingSupport
    module ControllerRequests
      extend ActiveSupport::Concern

      included do
        routes { Gesmew::Core::Engine.routes }
      end

      def gesmew_get(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_action(action, parameters, session, flash, "GET")
      end

      # Executes a request simulating POST HTTP method and set/volley the response
      def gesmew_post(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_action(action, parameters, session, flash, "POST")
      end

      # Executes a request simulating PUT HTTP method and set/volley the response
      def gesmew_put(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_action(action, parameters, session, flash, "PUT")
      end

      # Executes a request simulating DELETE HTTP method and set/volley the response
      def gesmew_delete(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_action(action, parameters, session, flash, "DELETE")
      end

      def gesmew_xhr_get(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_xhr_action(action, parameters, session, flash, :get)
      end

      def gesmew_xhr_post(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_xhr_action(action, parameters, session, flash, :post)
      end

      def gesmew_xhr_put(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_xhr_action(action, parameters, session, flash, :put)
      end

      def gesmew_xhr_delete(action, parameters = nil, session = nil, flash = nil)
        process_gesmew_xhr_action(action, parameters, session, flash, :delete)
      end

      private

      def process_gesmew_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
        parameters ||= {}
        process(action, method, parameters, session, flash)
      end

      def process_gesmew_xhr_action(action, parameters = nil, session = nil, flash = nil, method = :get)
        parameters ||= {}
        parameters.reverse_merge!(:format => :json)
        xml_http_request(method, action, parameters, session, flash)
      end
    end
  end
end
