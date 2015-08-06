module Gesmew
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: Rails.application.config.i18n.default_locale

    INSPECTION_TABS         ||= [:inspections]
    ESTABLISHMNET_TABS      ||= [:establishments]
    USER_TABS          ||= [:users]
  end
end
