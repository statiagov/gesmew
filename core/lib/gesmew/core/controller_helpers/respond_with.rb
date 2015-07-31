require 'gesmew/responder'

module ActionController
  class Base
    def respond_with(*resources, &block)
      if Gesmew::BaseController.gesmew_responders.keys.include?(self.class.to_s.to_sym)
        # Checkout AS Array#extract_options! and original respond_with
        # implementation for a better picture of this hack
        if resources.last.is_a? Hash
          resources.last.merge! action_name: action_name.to_sym
        else
          resources.push action_name: action_name.to_sym
        end
      end

      super
    end
  end
end

module Gesmew
  module Core
    module ControllerHelpers
      module RespondWith
        extend ActiveSupport::Concern

        included do
          cattr_accessor :gesmew_responders
          self.gesmew_responders = {}
          self.responder = Gesmew::Responder
        end

        module ClassMethods
          def clear_overrides!
            self.gesmew_responders = {}
          end

          def respond_override(options={})
            unless options.blank?
              action_name = options.keys.first
              action_value = options.values.first

              if action_name.blank? || action_value.blank?
                raise ArgumentError, "invalid values supplied #{options.inspect}"
              end

              format_name = action_value.keys.first
              format_value = action_value.values.first

              if format_name.blank? || format_value.blank?
                raise ArgumentError, "invalid values supplied #{options.inspect}"
              end

              if format_value.is_a?(Proc)
                options = {action_name.to_sym => {format_name.to_sym => {:success => format_value}}}
              end

              self.gesmew_responders.deep_merge!(self.name.to_sym => options)
            end
          end
        end
      end
    end
  end
end
