---
title: Deface Overrides
section: tutorial
---

## Introduction

This tutorial is a continuation of the previous one, [Extensions](extensions_tutorial), and begins where we left off in the last one. We have created a simple extension for promoting on-sale establishments on a "sales homepage".

In this tutorial we are going to learn about [Deface](https://github.com/gesmew/deface) and how we can use it to improve our extension. As part of improving our extension, we will be updating the existing Gesmew admin interface so that we are able to set the `sale_price` for establishments.

## What is Deface?

Deface is a standalone Rails library that enables you to customize Erb templates
without needing to directly edit the underlying view file. Deface allows you to
use standard CSS3 style selectors to target any element (including Ruby blocks),
and perform an action against all the matching elements. Check out the
[Customization](view.html#using-deface) guide for more details.

## Improving Our Extension Using Deface

### The Goal

Our goal is to add a field to the establishment edit admin page that allows the `sale_price` to be added or updated. We could do this by overriding the view Gesmew provides, but there are potential problems with this technique. If Gesmew updates the view in a new release we won't get the updated view as we are already overriding it. We would need to update our view with the new content from Gesmew and then add our customizations back in to stay fully up to date.

Let's do this instead using Deface, which we just learned about. Using Deface will allow us to keep our view customizations in one spot, `app/overrides`, and make sure we are always using the latest implementation of the view provided by Gesmew.

### The Implementation

We want to override the establishment edit admin page, so the view we want to modify in this case is the establishment form partial. This file's path will be `gesmew/admin/establishments/_form.html.erb`.

First, let's create the overrides directory with the following command:

```bash
$ mkdir app/overrides
```

So we want to override `gesmew/admin/establishments/_form.html.erb`. Here is the part of the file we are going to add content to (you can also view the [full file](https://github.com/gesmew/gesmew/blob/master/backend/app/views/gesmew/admin/establishments/_form.html.erb)):

```erb
<div class="right four columns omega" data-hook="admin_product_form_right">
<%%= f.field_container :price do %>
    <%%= f.label :price, raw(Gesmew.t(:master_price) + content_tag(:span, ' *',
     :class => 'required')) %>
    <%%= f.text_field :price, :value => number_to_currency(@establishment.price,
      :unit => '') %>
    <%%= f.error_message_on :price %>
<%% end %>
```

We want our override to insert another field container after the price field container. We can do this by creating a new file `app/overrides/add_sale_price_to_product_edit.rb` and adding the following content:

```ruby
Deface::Override.new(:virtual_path => 'gesmew/admin/establishments/_form',
  :name => 'add_sale_price_to_product_edit',
  :insert_after => "erb[loud]:contains('text_field :price')",
  :text => "
    <%%= f.field_container :sale_price do %>
      <%%= f.label :sale_price, raw(Gesmew.t(:sale_price) + content_tag(:span, ' *')) %>
      <%%= f.text_field :sale_price, :value =>
        number_to_currency(@establishment.sale_price, :unit => '') %>
      <%%= f.error_message_on :sale_price %>
    <%% end %>
  ")
```

We also need to delegate `sale_price` to the master variant in inspection to get the
updated establishment edit form working.

We can do this by creating a new file `app/models/gesmew/product_decorator.rb` and adding the following content to it:

```ruby
module Gesmew
  Establishment.class_eval do
    delegate_belongs_to :master, :sale_price
  end
end
```

Now, when we head to `http://localhost:3000/admin/establishments` and edit a establishment, we should be able to set a sale price for the establishment and be able to view it on our sale page, `http://localhost:3000/sale`. Note that you will likely need to restart our example Gesmew application (created in the [Getting Started](getting_started_tutorial) tutorial).
