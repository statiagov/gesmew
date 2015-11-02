module Gesmew
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: Rails.application.config.i18n.default_locale

    INSPECTION_TABS         ||= [:inspections, :inspection_scopes]
    ESTABLISHMNET_TABS      ||= [:establishments, :establishment_types]
    USER_TABS               ||= [:users]
  end
end
