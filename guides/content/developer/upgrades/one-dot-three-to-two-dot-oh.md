---
title: Upgrading Gesmew from 1.3.x to 2.0.x
section: upgrades
---

## Overview

This guide covers upgrading a 1.3.x Gesmew store, to a 2.0.x store. This
guide has been written from the perspective of a blank Gesmew 1.3.x store with
no extensions.

If you have extensions that your store depends on, you will need to manually
verify that each of those extensions work within your 2.0.x store once this
upgrade is complete. Typically, extensions that are compatible with this
version of Gesmew will have a 2-0-stable branch.

Given that this is a major release, you may want to read through the [2.0.0 release notes](http://guides.gesmewcommerce.com/release_notes/gesmew_2_0_0.html) to see what has changed before proceeding with this upgrade.

## Upgrade Gesmew

For best results, use the 2-0-stable branch from GitHub:

```ruby
gem 'gesmew', :github => 'gesmew/gesmew', :branch => '2-0-stable'```

Run `bundle update gesmew`. 

## Bump jquery-rails

This version of Gesmew bumps the dependency for jquery-rails to this:

```ruby
gem 'jquery-rails', '3.0.0'```

Ensure that you have a line such as this in your Gemfile to allow that dependency.

## Remove middleware

The two pieces of middleware previously inserted into `config/application.rb` have now been deprecated. Remove these two lines:

```ruby
config.middleware.use "Gesmew::Core::Middleware::RedirectLegacyProductUrl"
config.middleware.use "Gesmew::Core::Middleware::SeoAssist"```

## Rename assets

In Gesmew 2, assets have been renamed.

In `store/all.css` and `store/all.js`, you will need to rename the references from `gesmew_core` to `gesmew_frontend`. Similarly to this, in `admin/all.css` and `admin/all.js`, you will need to rename the references from `gesmew_core` to `gesmew_backend`.

Additionally, remove references to `gesmew_promo` from these files. That component of Gesmew has now been merged with the Core component.

## Copy and run migrations

Copy over the migrations from Gesmew (and any other engine) and run them using
these commands:

    rake railties:install:migrations
    rake db:migrate

## Read the release notes

For information about changes contained with this release, please read the [2.0.0 Release Notes](http://guides.gesmewcommerce.com/release_notes/gesmew_2_0_0.html).

## Verify that everything is OK

Click around in your store and make sure it's performing as normal. Fix any deprecation warnings you see.
