require 'rails/all'
require 'active_merchant'
require 'acts_as_list'
require 'awesome_nested_set'
require 'cancan'
require 'friendly_id'
require 'font-awesome-rails'
require 'kaminari'
require 'mail'
require 'monetize'
require 'paperclip'
require 'paranoia'
require 'premailer/rails'
require 'ransack'
require 'responders'
require 'state_machines-activerecord'

module Gesmew

  mattr_accessor :user_class

  def self.user_class
    if @@user_class.is_a?(Class)
      raise "Gesmew.user_class MUST be a String or Symbol object, not a Class object."
    elsif @@user_class.is_a?(String) || @@user_class.is_a?(Symbol)
      @@user_class.to_s.constantize
    end
  end

  # Used to configure Gesmew.
  #
  # Example:
  #
  #   Gesmew.config do |config|
  #     config.track_inventory_levels = false
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Gesmew.
  def self.config(&block)
    yield(Gesmew::Config)
  end

  module Core
    autoload :ProductFilters, "gesmew/core/product_filters"

    class GatewayError < RuntimeError; end
    class DestroyWithOrdersError < StandardError; end
  end
end

require 'gesmew/core/version'

require 'gesmew/core/environment_extension'
require 'gesmew/core/environment'
require 'gesmew/core/number_generator'
require 'gesmew/promo/environment'
require 'gesmew/migrations'
require 'gesmew/core/engine'

require 'gesmew/i18n'
require 'gesmew/localized_number'
require 'gesmew/money'
require 'gesmew/permitted_attributes'
require 'gesmew/utf8_cleaner'
require 'gesmew/open_object'
require 'gesmew/core/delegate_belongs_to'
require 'gesmew/core/importer'
require 'gesmew/core/controller_helpers/auth'
require 'gesmew/core/controller_helpers/common'
require 'gesmew/core/controller_helpers/respond_with'
require 'gesmew/core/controller_helpers/search'
require 'gesmew/core/controller_helpers/strong_parameters'
