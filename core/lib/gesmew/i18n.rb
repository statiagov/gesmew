require 'i18n'
require 'active_support/core_ext/array/extract_options'
require 'gesmew/i18n/base'
require 'action_view'

module Gesmew
  extend ActionView::Helpers::TranslationHelper
  extend ActionView::Helpers::TagHelper

  class << self
    # Add gesmew namespace and delegate to Rails TranslationHelper for some nice
    # extra functionality. e.g return reasonable strings for missing translations
    def translate(*args)
      @virtual_path = virtual_path

      options = args.extract_options!
      options[:scope] = [*options[:scope]].unshift(:gesmew)
      args << options
      super(*args)
    end

    alias_method :t, :translate

    def context
      Gesmew::ViewContext.context
    end

    def virtual_path
      if context
        path = context.instance_variable_get("@virtual_path")

        if path
          path.gsub(/gesmew/, '')
        end
      end
    end
  end
end
