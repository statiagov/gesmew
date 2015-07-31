module Gesmew
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Gesmew
      engine_name 'gesmew'

      rake_tasks do
        load File.join(root, "lib", "tasks", "exchanges.rake")
      end

      initializer "gesmew.environment", :before => :load_config_initializers do |app|
        app.config.gesmew = Gesmew::Core::Environment.new
        Gesmew::Config = app.config.gesmew.preferences #legacy access
      end

      # initializer "gesmew.register.calculators" do |app|
      #   app.config.gesmew.calculators.shipping_methods = [
      #       Gesmew::Calculator::Shipping::FlatPercentItemTotal,
      #       Gesmew::Calculator::Shipping::FlatRate,
      #       Gesmew::Calculator::Shipping::FlexiRate,
      #       Gesmew::Calculator::Shipping::PerItem,
      #       Gesmew::Calculator::Shipping::PriceSack]
      #
      #    app.config.gesmew.calculators.tax_rates = [
      #       Gesmew::Calculator::DefaultTax]
      # end
      #
      # initializer "gesmew.register.stock_splitters" do |app|
      #   app.config.gesmew.stock_splitters = [
      #     Gesmew::Stock::Splitter::ShippingCategory,
      #     Gesmew::Stock::Splitter::Backordered
      #   ]
      # end
      #
      # initializer "gesmew.register.payment_methods" do |app|
      #   app.config.gesmew.payment_methods = [
      #       Gesmew::Gateway::Bogus,
      #       Gesmew::Gateway::BogusSimple,
      #       Gesmew::PaymentMethod::Check ]
      # end
      #
      # initializer "gesmew.register.adjustable_adjusters" do |app|
      #   app.config.gesmew.adjusters = [
      #     Gesmew::Adjustable::Adjuster::Promotion,
      #     Gesmew::Adjustable::Adjuster::Tax]
      # end
      #
      # # We need to define promotions rules here so extensions and existing apps
      # # can add their custom classes on their initializer files
      # initializer 'gesmew.promo.environment' do |app|
      #   app.config.gesmew.add_class('promotions')
      #   app.config.gesmew.promotions = Gesmew::Promo::Environment.new
      #   app.config.gesmew.promotions.rules = []
      # end
      #
      # initializer 'gesmew.promo.register.promotion.calculators' do |app|
      #   app.config.gesmew.calculators.add_class('promotion_actions_create_adjustments')
      #   app.config.gesmew.calculators.promotion_actions_create_adjustments = [
      #     Gesmew::Calculator::FlatPercentItemTotal,
      #     Gesmew::Calculator::FlatRate,
      #     Gesmew::Calculator::FlexiRate,
      #     Gesmew::Calculator::TieredPercent,
      #     Gesmew::Calculator::TieredFlatRate
      #   ]
      #
      #   app.config.gesmew.calculators.add_class('promotion_actions_create_item_adjustments')
      #   app.config.gesmew.calculators.promotion_actions_create_item_adjustments = [
      #     Gesmew::Calculator::PercentOnLineItem,
      #     Gesmew::Calculator::FlatRate,
      #     Gesmew::Calculator::FlexiRate
      #   ]
      # end
      #
      # # Promotion rules need to be evaluated on after initialize otherwise
      # # Gesmew.user_class would be nil and users might experience errors related
      # # to malformed model associations (Gesmew.user_class is only defined on
      # # the app initializer)
      # config.after_initialize do
      #   Rails.application.config.gesmew.promotions.rules.concat [
      #     Gesmew::Promotion::Rules::ItemTotal,
      #     Gesmew::Promotion::Rules::Product,
      #     Gesmew::Promotion::Rules::User,
      #     Gesmew::Promotion::Rules::FirstOrder,
      #     Gesmew::Promotion::Rules::UserLoggedIn,
      #     Gesmew::Promotion::Rules::OneUsePerUser,
      #     Gesmew::Promotion::Rules::Taxon,
      #     Gesmew::Promotion::Rules::OptionValue
      #   ]
      # end
      #
      # initializer 'gesmew.promo.register.promotions.actions' do |app|
      #   app.config.gesmew.promotions.actions = [
      #     Promotion::Actions::CreateAdjustment,
      #     Promotion::Actions::CreateItemAdjustments,
      #     Promotion::Actions::CreateLineItems,
      #     Promotion::Actions::FreeShipping]
      # end

      # filter sensitive information during logging
      initializer "gesmew.params.filter" do |app|
        app.config.filter_parameters += [
          :password,
          :password_confirmation,
          :number,
          :verification_value]
      end

      initializer "gesmew.core.checking_migrations" do |app|
        Migrations.new(config, engine_name).check
      end

      config.to_prepare do
        # Load application's model / class decorators
        Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end
    end
  end
end

require 'gesmew/core/routes'
