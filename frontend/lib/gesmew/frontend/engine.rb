module Gesmew
  module Frontend
    class Engine < ::Rails::Engine
      config.middleware.use "Gesmew::Frontend::Middleware::SeoAssist"

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "gesmew.assets.precompile", group: :all do |app|
        app.config.assets.precompile += %w[
          gesmew/frontend/all*
          jquery.validate/localization/messages_*
        ]
      end

      initializer "gesmew.frontend.environment", before: :load_config_initializers do |app|
        Gesmew::Frontend::Config = Gesmew::FrontendConfiguration.new
      end
    end
  end
end
