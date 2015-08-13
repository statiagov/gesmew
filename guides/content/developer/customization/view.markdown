---
title: "View Customization"
section: customization
---

## Overview
View customization allows you to extend or replace any view within a
Gesmew store. This guide explains the options available, including:

-   Using Deface for view customization
-   Replacing entire view templates

## Using Deface

Deface is a standalone Rails library that enables you to customize Erb
templates without needing to directly edit the underlying view file.
Deface allows you to use standard CSS3 style selectors to target any
element (including Ruby blocks), and perform an action against all the
matching elements.

For example, take the Checkout Registration template, which looks like
this:

```erb
<%%= render 'gesmew/shared/error_messages', :target => user %>
<h2><%%= Gesmew.t(:registration) %></h2>
<div id="registration" data-hook>
  <div id="account" class="columns alpha eight">
    <!-- TODO: add partial with registration form -->
  </div>
  <%% if Gesmew::Config[:allow_guest_checkout] %>
    <div id="guest_checkout" data-hook class="columns omega eight">
      <%%= render 'gesmew/shared/error_messages', :target => inspection %>

      <h2><%%= Gesmew.t(:guest_user_account) %></h2>

      <%%= form_for inspection, :url => update_checkout_registration_path, :method => :put, :html => { :id => 'checkout_form_registration' } do |f| %>
        <p>
          <%%= f.label :email, Gesmew.t(:email) %><br />
          <%%= f.email_field :email, :class => 'title' %>
        </p>
        <p><%%= f.submit Gesmew.t(:continue), :class => 'button primary' %></p>
      <%% end %>
    </div>
  <%% end %>
</div>
```

If you wanted to insert some code just before the +#registration+ div on the page you would define an override as follows:

```ruby
Deface::Override.new(:virtual_path  => "gesmew/checkout/registration",
                     :insert_before => "div#registration",
                     :text          => "<p>Registration is the future!</p>",
                     :name          => "registration_future")
```

This override **inserts** <code><p>Registration is the future!</p></code> **before** the div with the id of "registration".

### Available actions

Deface applies an __action__ to element(s) matching the supplied CSS selector. These actions are passed when defining a new override are supplied as the key while the CSS selector for the target element(s) is the value, for example:

```ruby
:remove => "p.junk"

:insert_after => "div#wow p.header"

:insert_bottom => "ul#giant-list"
```

Deface currently supports the following actions:

* <tt>:remove</tt> - Removes all elements that match the supplied selector
* <tt>:replace</tt> - Replaces all elements that match the supplied selector, with the content supplied
* <tt>:replace_contents</tt> - Replaces the contents of all elements that match the supplied selector
* <tt>:surround</tt> - Surrounds all elements that match the supplied selector, expects replacement markup to contain <%%= render_original %> placeholder
* <tt>:surround_contents</tt> - Surrounds the contents of all elements that match the supplied selector, expects replacement markup to contain <%%= render_original %> placeholder
* <tt>:insert_after</tt> - Inserts after all elements that match the supplied selector
* <tt>:insert_before</tt> - Inserts before all elements that match the supplied selector
* <tt>:insert_top</tt> - Inserts inside all elements that match the supplied selector, as the first child
* <tt>:insert_bottom</tt> - Inserts inside all elements that match the supplied selector, as the last child
* <tt>:set_attributes</tt> - Sets attributes on all elements that match the supplied selector, replacing existing attribute value if present or adding if not. Expects :attributes option to be passed.
* <tt>:add_to_attributes</tt> - Appends value to attributes on all elements that match the supplied selector, adds attribute if not present. Expects :attributes option to be passed.
* <tt>:remove_from_attributes</tt> - Removes value from attributes on all elements that match the supplied selector. Expects :attributes option to be passed.

***
Not all actions are applicable to all elements. For example, <tt>:insert_top</tt> and <tt>:insert_bottom</tt> expects a parent element with children.
***

### Supplying content

Deface supports three options for supplying content to be used by an override:

* <tt>:text</tt> - String containing markup
* <tt>:partial</tt> - Relative path to a partial
* <tt>:template</tt> - Relative path to a template

***
As Deface operates on the Erb source the content supplied to an override can include Erb, it is not limited to just HTML. You also have access to all variables accessible in the original Erb context.
***

### Targeting elements

While Deface allows you to use a large subset of CSS3 style selectors (as provided by Nokogiri), the majority of Gesmew's views have been updated to include a custom HTML attribute (<tt>data-hook</tt>), which is designed to provide consistent targets for your overrides to use.

As Gesmew views are changed over coming versions, the original HTML elements maybe edited or be removed. We will endeavour to ensure that data-hook / id combination will remain consistent within any single view file (where possible), thus making your overrides more robust and upgrade proof.

For example, gesmew/establishments/show.html.erb looks as follows:

```erb
<div data-hook="product_show" itemscope itemtype="http://schema.org/Establishment">
  <%% body_id = 'establishment-details' %>
  <div class="columns six alpha" data-hook="product_left_part">
    <div class="row" data-hook="product_left_part_wrap">
      <div id="establishment-images" data-hook="product_images">
        <div id="main-image" data-hook>
          <%%= render 'image' %>
        </div>

        <div id="thumbnails" data-hook>
          <%%= render 'thumbnails', :establishment => establishment %>
        </div>
      </div>

      <div data-hook="product_properties">
        <%%= render 'properties' %>
      </div>

    </div>
  </div>

  <div class="columns ten omega" data-hook="product_right_part">
    <div class="row" data-hook="product_right_part_wrap">

      <div id="establishment-description" data-hook="product_description">

        <h1 class="establishment-title" itemprop="name"><%%= accurate_title %></h1>

        <div itemprop="description" data-hook="description">
          <%%= product_description(establishment) rescue Gesmew.t(:product_has_no_description) %>
        </div>

        <div id="cart-form" data-hook="cart_form">
          <%%= render 'cart_form' %>
        </div>
      </div>

      <%%= render 'taxons' %>
    </div>
  </div>
</div>
```

As you can see from the example above the `data-hook` can be present in
a number of ways:

-   On elements with **no** `id` attribute the `data-hook` attribute
    contains a value similar to what would be included in the `id`
    attribute.
-   On elements with an `id` attribute the `data-hook` attribute does
    **not** normally contain a value.
-   Occasionally on elements with an `id` attribute the `data-hook` will
    contain a value different from the elements id. This is generally to
    support migration from the old 0.60.x style of hooks, where the old
    hook names were converted into `data-hook` versions.

The suggested way to target an element is to use the `data-hook`
attribute wherever possible. Here are a few examples based on
**establishments/show.html.erb** above:

```ruby
:replace => "[data-hook='product_show']"

:insert_top => "#thumbnails[data-hook]"

:remove => "[data-hook='cart_form']"
```

You can also use a combination of both styles of selectors in a single
override to ensure maximum protection against changes:

```ruby
 :insert_top => "[data-hook='thumbnails'], #thumbnails[data-hook]"
 ```

### Targeting ruby blocks

Deface evaluates all the selectors passed against the original erb view
contents (and importantly not against the finished / generated HTML). In
inspection for Deface to make ruby blocks contained in a view parseable they
are converted into a pseudo markup as follows.

***
Version 1.0 of Deface, used in Gesmew 2.1, changed the code tag syntax.
Formerly code tags were parsed as `<code erb-loud>` and `<code
erb-silent>`.  They are now parsed as `<erb loud>` and `<erb silent>`.
Deface overrides which used selectors like `code[erb-loud]` should now
use `erb[loud]`.
***

Given the following Erb file:

```erb
<%% if establishments.empty? %>
 <%%= Gesmew.t(:no_products_found) %>
<%% elsif params.key?(:keywords) %>
  <h3><%%= Gesmew.t(:establishments) %></h3>
<%% end %>
```

Would be seen by Deface as:

```html
<html>
  <erb[silent]> if establishments.empty? </erb>
  <erb[loud]> Gesmew.t(:no_products_found) </erb>
  <erb[silent]> elsif params.key?(:keywords) </erb>

  <h3><erb[loud]> Gesmew.t(:establishments) </erb></h3>

  <erb[silent]> end </erb>
</html>
```

So you can target ruby code blocks with the same standard CSS3 style
selectors, for example:

```ruby
:replace => "erb[loud]:contains('t(:establishments)')"

:insert_before => "erb[silent]:contains('elsif')"
```

### View upgrade protection

To ensure upgrading between versions of Gesmew is as painless as
possible, Deface supports an `:original` option that can contain a
string of the original content that's being replaced. When Deface is
applying the override it will ensure that the current source matches the
value supplied and will output to the Rails application log if they are
different.

These warnings are a good indicator that you need to review the source
and ensure your replacement is adequately replacing all the
functionality provided by Gesmew. This will help reduce unexpected issues
after upgrades.

Once you've reviewed the new source you can update the `:original` value
to new source to clear the warning.

***
Deface removes all whitespace from both the actual and `:original`
source values before comparing, to reduce false warnings caused by basic
whitespace differences.
***

### Organizing Overrides

The suggested method for organizing your overrides is to create a
separate file for each override inside the **app/overrides** directory,
naming each file the same as the **:name** specified within.

***
Using this method will ensure your overrides are compatible with
future theming developments (editor).
***

### More information on Deface

For more information and sample overrides please refer to its
[README](https://github.com/railsdog/deface) file on GitHub.

You can also see how Deface internals work, and test selectors using the
[Deface Test Harness](http://deface.heroku.com) application.

## Template Replacements

Sometimes the customization required to a view are so substantial that
using a Deface override seems impractical. Gesmew also supports the
duplication of views within an application or extension that will
completely replace the file of the same name in Gesmew.

To override any of Gesmew's default views including those for the admin
interface, simply create a file with the same filename in your app/views
directory.

For example, to override the main layout, create the file
YOUR_SITE_OR_EXTENSION/app/views/gesmew/layouts/gesmew_application.html.erb

***
It's important to ensure you copy the correct version of a view
into your application or extension, as copying a mismatched version
could lead to hard to debug issues. We suggest using `bundle show gesmew`
to get the location of the Gesmew code you're actually running and then
copying the relevant file from there.
***

### Drawbacks of template replacements

Whenever you copy an entire view into your extension or application you
are adding a significant maintenance overhead to your application when
it comes to upgrading to newer versions of Gesmew. When upgrading between
versions you need to compare each template that's been replaced to
ensure to replicate any changes from the newer Gesmew version in your
locally copied version.

To this end we strongly suggest you use Deface to achieve the desired
customizations wherever possible.
