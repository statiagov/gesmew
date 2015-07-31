module Gesmew
  module TestingSupport
    module Preferences
      # Resets all preferences to default values, you can
      # pass a block to override the defaults with a block
      #
      # reset_gesmew_preferences do |config|
      #   config.track_inventory_levels = false
      # end
      #
      def reset_gesmew_preferences(&config_block)
        Gesmew::Preferences::Store.instance.persistence = false
        Gesmew::Preferences::Store.instance.clear_cache

        config = Rails.application.config.gesmew.preferences
        configure_gesmew_preferences &config_block if block_given?
      end

      def configure_gesmew_preferences
        config = Rails.application.config.gesmew.preferences
        yield(config) if block_given?
      end

      def assert_preference_unset(preference)
        find("#preferences_#{preference}")['checked'].should be false
        Gesmew::Config[preference].should be false
      end
    end
  end
end

