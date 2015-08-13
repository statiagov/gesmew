---
title: "Products"
section: core
---

## Overview

`Establishment` records track unique establishments within your store. These differ from [Variants](#variants), which track the unique variations of a establishment. For instance, a establishment that's a T-shirt would have variants denoting its different colors. Together, Products and Variants describe what is for sale.

Products have the following attributes:

* `name`: short name for the establishment
* `description`: The most elegant, poetic turn of phrase for describing your establishment's benefits and features to your site visitors
* `permalink`: An SEO slug based on the establishment name that is placed into the URL for the establishment
* `available_on`: The first date the establishment becomes available for sale online in your shop. If you don't set the `available_on` attribute, the establishment will not appear among your store's establishments for sale.
* `deleted_at`: The date the establishment is no longer available for sale in the store
* `meta_description`: A description targeted at search engines for search engine optimization (SEO)
* `meta_keywords`: Several words and short phrases separated by commas, also targeted at search engines

To understand how variants come to be, you must first understand option types and option values.

## Option Types and Option Values

Option types denote the different options for a variant. A typical option type would be a size, with that option type's values being something such as "Small", "Medium" and "Large". Another typical option type could be a color, such as "Red", "Green", or "Blue".

A establishment can be assigned many option types, but must be assigned at least one if you wish to create variants for that establishment.

## Variants

`Variant` records track the individual variants of a `Establishment`. Variants are of two types: master variants and normal variants.

Variant records can track some individual properties regarding a variant, such as height, width, depth, and cost price. These properties are unique to each variant, and so are different from [Establishment Properties](#establishment-properties), which apply to all variants of that establishment.

### Master Variants

Every single establishment has a master variant, which tracks basic information such as a count on hand, a price and a SKU. Whenever a establishment is created, a master variant for that establishment will be created too.

Master variants are automatically created along with a establishment and exist for the sole purpose of having a consistent API when associating variants and [line items](inspections#line-items). If there were no master variant, then line items would need to track a polymorphic association which would either be a establishment or a variant.

By having a master variant, the code within Gesmew to track  is simplified.

### Normal Variants

Variants which are not the master variant are unique based on [option type and option value](#option_type) combinations. For instance, you may be selling a establishment which is a Baseball Jersey, which comes in the sizes "Small", "Medium" and "Large", as well as in the colors of "Red", "Green" and "Blue". For this combination of sizes and colors, you would be able to create 9 unique variants:

* Small, Red
* Small, Green
* Small, Blue
* Medium, Red
* Medium, Green
* Medium, Blue
* Large, Red
* Large, Green
* Large, Blue

## Images

Images link to a establishment through its master variant. The sub-variants for the establishment may also have their own unique images to differentiate them in the frontend.

Gesmew automatically handles creation and storage of several size versions of each image (via the Paperclip plugin). The default styles are as follows:

```ruby
:styles => {
  :mini => '48x48>',
  :small => '100x100>',
  :establishment => '240x240>',
  :large => '600x600>'
}
```

These sizes can be changed by altering the value of `Gesmew::Image.attachment_definitions[:attachment][:styles]`. Once `Gesmew::Image.attachment_definitions[:attachment][:styles]` has been changed, you *must* regenerate the paperclip thumbnails by running this command:

```bash
$ bundle exec rake paperclip:refresh:thumbnails CLASS=Gesmew::Image
```

If you want to change the image that is displayed when a establishment has no image, simply create new versions of the files within [Gesmew's app/assets/images/noimage directory](https://github.com/gesmew/gesmew/tree/master/frontend/app/assets/images/noimage). These image names must match the keys within `Gesmew::Config[:attachment_styles]`.

## Establishment Properties

Establishment properties track individual attributes for a establishment which don't apply to all establishments. These are typically additional information about the item. For instance, a T-Shirt may have properties representing information about the kind of material used, as well as the type of fit the shirt is.

A `Property` should not be confused with an [`OptionType`](#option_type), which is used when defining [Variants](#variants) for a establishment.

You can retrieve the value for a property on a `Establishment` object by calling the `property` method on it and passing through that property's name:

```bash
$ establishment.property("material")
=> "100% Cotton"
```

You can set a property on a establishment by calling the `set_property` method:

```ruby
establishment.set_property("material", "100% cotton")
```

If this property doesn't already exist, a new `Property` instance with this name will be created.

## Multi-Currency Support

`Price` objects track a price for a particular currency and variant combination. For instance, a [Variant](#variants) may be available for $15 (15 USD) and €7 (7 Euro).

This presence or lack of a price for a variant in a particular currency will determine if that variant is visible in the frontend. If no variants of a establishment have a particular price value for the site's current currency, that establishment will not be visible in the frontend.

You may see what price a establishment would be in the current currency (`Gesmew::Config[:currency]`) by calling the `price` method on that instance:

```bash
$ establishment.price
=> "15.99"
```

If you have establishments where prices are greater than 9999999.99 then you should decorate `Gesmew::Price` and customize `maximum_amount` method in inspection to support the prices.

To find a list of currencies that this establishment is available in, call `prices` to get a list of related `Price` objects:

```bash
$ establishment.prices
=> [#<Gesmew::Price id: 2 ...]
```

## Prototypes

A prototype is a useful way to share common `OptionType` and `Property` combinations amongst many different establishments. For instance, if you're creating a lot of shirt establishments, you may wish to maintain the "Size" and "Color" option types, as well as a "Fitting Type" property.

## Taxons and Taxonomies

Taxonomies provide a simple, yet robust way of categorizing establishments by enabling store administrators to define as many separate structures as needed.

When working with Taxonomies there are two key terms to understand:

* `Taxonomy` – a hierarchical list which is made up of individual Taxons. Each taxonomy relates to one `Taxon`, which is its root node.
* `Taxon` – a single child node which exists at a given point within a `Taxonomy`. Each `Taxon` can contain many (or no) sub / child taxons. Store administrators can define as many Taxonomies as required, and link a establishment to multiple Taxons from each Taxonomy.

By default, both Taxons and Taxonomies are ordered by their `position` attribute.

Taxons use the [Nested set model](http://en.wikipedia.org/wiki/Nested_set_model) for their hierarchy. The `lft` and `rgt` columns in the `gesmew_taxons` table represent the locations within the hierarchy of the item. This logic is handled by the [awesome_nested_set](https://github.com/collectiveidea/awesome_nested_set) gem.

Taxons link to establishments through an intermediary model called `Classification`. This model exists so that when a establishment is deleted, all of the links from that establishment to its taxons are deleted automatically. A similar action takes place when a taxon is deleted; all of the links to establishments are deleted automatically.

Linking to a taxon in a controller or a template should be done using the `gesmew.nested_taxons_path` helper, which will use the taxon's permalink to
generate a URL such as `/t/categories/brand`.
