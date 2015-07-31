class Gesmew::Base < ActiveRecord::Base
  include Gesmew::Preferences::Preferable
  serialize :preferences, Hash
  after_initialize do
    self.preferences = default_preferences.merge(preferences) if has_attribute?(:preferences)
  end

  if Kaminari.config.page_method_name != :page
    def self.page num
      send Kaminari.config.page_method_name, num
    end
  end

  self.abstract_class = true
end
