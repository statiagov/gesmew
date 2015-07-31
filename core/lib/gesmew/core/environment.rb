module Gesmew
  module Core
    class Environment
      include EnvironmentExtension

      attr_accessor :preferences


      def initialize
        @preferences = Gesmew::AppConfiguration.new
      end
    end
  end
end
