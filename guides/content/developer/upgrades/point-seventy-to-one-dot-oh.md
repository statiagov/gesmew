---
title: Upgrading Gesmew from 0.70.x to 1.0.x
section: upgrades
---

## Overview

This guide covers upgrading a 0.70.x Gesmew store, to a 1.0.x store. This
guide has been written from the perspective of a blank Gesmew 0.70.x store with
no extensions.

If you have extensions that your store depends on, you will need to manually
verify that each of those extensions work within your 1.0.x store once this
upgrade is complete. Typically, extensions that are compatible with this
version of Gesmew will have a 1-0-stable branch.

Worth noting here is that Gesmew 1.0 was the first release to properly use the
features of Rails engines. This means that Gesmew needs to be mounted manually
within the `config/routes.rb` file of the application, and that the classes
such as `Product` and `Variant` from Gesmew are now namespaced within a module,
so that they are now `Gesmew::Product` and `Gesmew::Variant`. Tables are
similarly namespaced (i.e. `gesmew_products` and `gesmew_variants`).

Along with this, migrations must be copied over to the application using the
`rake railties:install:migrations` command, rather than a `rails g gesmew:site`
command as before.

## Upgrade Rails

Gesmew 1.0 depends on any Rails 3.1 release afer Rails 3.1.10. Ensure that you have that dependency specified in your Gemfile:

```ruby
gem 'rails', '~> 3.1.10'

## Upgrade Gesmew

For best results, use the 1-0-stable branch from GitHub:

```ruby
gem 'gesmew', :github => 'gesmew/gesmew', :branch => '1-0-stable'```

Run `bundle update gesmew`. 

## Rename middleware classes

In `config/application.rb`, there are two pieces of middleware:

```ruby
config.middleware.use "RedirectLegacyProductUrl"
config.middleware.use "SeoAssist"```

These classes are now namespaced within Gesmew:

```ruby
config.middleware.use "Gesmew::Core::Middleware::RedirectLegacyProductUrl"
config.middleware.use "Gesmew::Core::Middleware::SeoAssist"```


## Copy and run migrations

Copy over the migrations from Gesmew (and any other engine) and run them using
these commands:

    rake railties:install:migrations
    rake db:migrate

## Mount the Gesmew engine

Within `config/routes.rb`, you must now mount the Gesmew engine:

```ruby
mount Gesmew::Core::Engine, :at => '/'```

This is the standard way of adding engines to Rails applications.

## Remove gesmew_dash assets

Gesmew's dash component was removed as a dependency of Gesmew, and so references
to its assets must be removed also. Remove references to gesmew_dash from:

* app/assets/stylesheets/store/all.css
* app/assets/javascripts/store/all.js
* app/assets/stylesheets/admin/all.css
* app/assets/javascripts/admin/all.js

## Verify that everything is OK

Click around in your store and make sure it's performing as normal. Fix any deprecation warnings you see.
