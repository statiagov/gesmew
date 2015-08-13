module Gesmew
  module Backend
    class Engine < ::Rails::Engine
      config.middleware.use "Gesmew::Backend::Middleware::SeoAssist"

      initializer "gesmew.backend.environment", :before => :load_config_initializers do |app|
        Gesmew::Backend::Config = Gesmew::BackendConfiguration.new
      end

      # filter sensitive information during logging
      initializer "gesmew.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :number]
      end

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "gesmew.assets.precompile", :group => :all do |app|
        app.config.assets.paths << "#{Rails.root}/app/assets/fonts"
        app.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

        app.config.assets.precompile += %w[
          gesmew/backend/all*
          gesmew/backend/inspections/edit_form.js
          gesmew/backend/address_states.js
          jqPlot/excanvas.min.js
          gesmew/backend/images/new.js
          jquery.jstree/themes/gesmew/*
          fontawesome-webfont*
          select2_locale*
          jquery.alerts/images/*
        ]
      end
    end
  end
end
