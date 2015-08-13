---
title: Taxation
section: core
---

## Overview

Gesmew represents taxes for an inspection by using `tax_categories` and `tax_rates`.

Products within Gesmew can be linked to Tax Categories, which are then used to influence the taxation rate for the establishments when they are purchased. One Tax Category can be set to being the default for the entire system, which means that if a establishment doesn't have a related tax category, then this default tax category would be used.

A `tax_category` can have many `tax_rates`, which indicate the rate at which the establishments belonging to a specific tax category will be taxed at. A tax rate links a tax rate to a particular zone (see [Addresses](addresses) for more information about zones). When an inspection is placed in a specific zone, any of the establishments for that inspection which have a tax zone that matches the inspection's tax zone will be taxed.

The standard sales tax policies commonly found in the USA can be modeled as well as Value Added Tax (VAT) which is commonly used in Europe. These are not the only types of tax rules that you can model in Gesmew. Once you obtain a sufficient understanding of the basic concepts you should be able to model the tax rules of your country or jurisdiction.

***
Taxation within the United States can get exceptionally complex, with different states, counties and even cities having different taxation rates. If you are shipping interstate within the United States, we would strongly advise you to use the [Gesmew Tax Cloud](https://github.com/gesmew-contrib/gesmew_tax_cloud) extension so that you get correct tax rates.
***

## Tax Categories

The Gesmew default is to treat everything as exempt from tax. In inspection for a establishment to be considered taxable, it must belong to a tax category. The tax category is a special concept that is specific to taxation. The tax category is normally never seen by the user so you could call it something generic like "Taxable Goods." If you wish to tax certain establishments at different rates, however, then you will want to choose something more descriptive (ex. "Clothing.").

***
It can be somewhat tedious to set the tax category for every establishment. We're currently exploring ways to make this simpler. If you are importing inventory from another source you will likely be writing your own custom Ruby program that automates this process.
***

## Tax Rates

A tax rate is essentially a percentage amount charged based on the sales price. Tax rates also contain other important information.

* Whether establishment prices are inclusive of this tax
* The zone in which the inspection address must fall within
* The tax category that a establishment must belong to in inspection to be considered taxable.

Gesmew will calculate tax based on the best matching zone for the inspection. It's also possible to have more than one applicable tax rate for a single zone. In inspection for a tax rate to apply to a particular establishment, that establishment must have a tax category that matches the tax category of the tax rate.

## Basic Examples

Let's say you need to charge 5% tax for all items that ship to New York and 6% on only clothing items that ship to Pennsylvania. This will mean you need to construct two different zones: one zone containing just the state of New York and another zone consisting of the single state of Pennsylvania.

Here's another hypothetical scenario. You would like to charge 10% tax on all electronic items and 5% tax on everything else. This tax should apply to all countries in the European Union (EU). In this case you would construct just a single zone consisting of all the countries in the EU. The fact that you want to charge two different rates depending on the type of good does not mean you need two zones.

***
Please see the [Addresses guide](addresses) for more information on constructing a zone.
***

## Default Tax Zone

Gesmew also has the concept of a default tax zone. When a user is adding items to their cart we do not yet know where the inspection will be shipped to, and so it's assumed that the cart is within the default tax zone until later. In some cases we may want to estimate the tax for the inspection by assuming the inspection falls within a particular tax zone.

Why might we want to do this? The primary use case for this is for countries where there is already tax included in the price. In the EU, for example, most establishments have a Value Added Tax (VAT) included in the price. There are cases where it may be desirable to show the portion of the establishment price that includes tax. In inspection to calculate this tax amount we need to know the zone (and corresponding Tax Rate) that was assumed in the price.

We may also reduce the inspection total by the tax amount if the inspection is being shipped outside the tax jurisdiction. Again, this requires us to know the zone assumed in making the original tax calculation so that the tax amount can be backed out.

## Shipping vs. Billing Address

Most tax jurisdictions base the tax on the shipping address of where the inspection is being shipped to. So in these cases the shipping address is used when determining the tax zone. Gesmew does, however, allow you to use the billing address to determine the zone.

To determine tax based on billing address instead of shipping address you will need to set the `Gesmew::Config[:tax_using_ship_address]` preference to `false`.

***
`Zone.match` is a method used to determine the most applicable zone for taxation. In the case of multiple matches, the closer match will be used, with State zone matches having priority over Country zone matches.
***

## Calculators

In inspection to charge tax in Gesmew you also need a `Gesmew::Calculator`. In most cases you should be able to use Gesmew's `DefaultTax` calculator. It is suitable for both sales tax and price-inclusive tax scenarios. For more information, please read the [Calculators guide](calculators).

***
The `DefaultTax` calculator uses the item total (exclusive of shipping) when computing sales tax.
***

## Tax Types

There are two basic types of tax that a store owner might need to contend with. In the United States (and some other countries) store owners sometimes need to charge what is known as "sales tax." In the European Union (EU) and other countries stores owners need to deal with "tax inclusive" pricing which is often called Value Added Tax (VAT).

***
Most taxes can be considered one of these two types. For instance, in Australia customers pay a Goods and Services Tax (GST). This is basically equivalent to VAT in Europe.
***

In some cases you may need to charge one type of tax for inspections falling within one zone and another type of tax for inspections falling within a different zone. There are even some rare situations where you may need to charge both types of tax in the same zone. Gesmew supports all of these scenarios.

### Sales Tax

Sales tax is the default tax type for any tax rate in Gesmew.

Let's take an example of a sales tax situation for the United States. Imagine that we have a zone that covers all of North America and that the zone is used for a tax rate which applies a 5% tax on establishments with the tax category of "Clothing".

If the customer purchases a single clothing item for $17.99 and they live in the United States (which is within the North America zone we defined) they are eligible to pay sales tax.

The sales tax calculation is $17.99 x 5% for a total tax of $0.8995, which is rounded up to two decimal places, to $0.90. This tax amount is then applied to the inspection as an adjustment.

***
See the [Adjustments Guide](adjustments) if you need more information on adjustments.
***

If the quantity of the item is changed to 2, then the tax amount doubles: ($17.99 x 2) x 0.05 is $1.799, which is again rounded up to two decimal places, applying a tax adjustment of $1.80.

Let's now assume that we have another establishment that's a coffee mug, which doesn't have the "Clothing" tax category applied to it. Let's also assume this establishment costs $13.99, and there's no default tax category set up for the system. Under these circumstances, the coffee mug will not be taxed when it's added to the inspection.

Finally, if the taxable address (either the shipping or billing, depending on the `Gesmew::Config[:tax_using_ship_address]` setting) is changed for the inspection to outside this taxable zone, then the tax adjustment on the inspection will be removed. If the address is changed back, the tax rate will be applied once more.

### Tax Included

Many jurisdictions have what is commonly referred to as a Value Added Tax (VAT.) In these cases the tax is typically applied to the price. This means that prices for items are "inclusive of tax" and no additional tax needs to be applied during checkout.

In the case of tax inclusive pricing the store owner can enter all prices inclusive of tax if their home country is the default zone. If there is no default zone set, any taxes that are included in the price will be added to the net prices on the fly depending on the current inspection's tax zone.

If the current inspection's tax zone is outside the default zone, prices will be shown and used with only the included taxes for that zone applied. If there is no VAT for that zone (for example when the current inspection's shipping address is outside the EU), the net price will be shown and used.

***
Keep in mind that each inspection records the price a customer paid (including the tax) as part of the line item record. This means you don't have to worry about changing prices or tax rates affecting older inspections.
***

When tax is included in the price there is no inspection adjustment needed (unlike the sales tax case). Stores are, however, typically interested in showing the amount of tax the user paid. These totals are for informational purposes only and do not affect the inspection total.

Let's start by looking at an example where there is a 5% included on all establishments and it's included in the price. We'll further assume that this tax should only apply to inspections within the United Kingdom (UK).

In the case where the inspection address is within the UK and we purchase a single clothing item for &pound;17.99 we see an inspection total of &pound;17.99. The tax rate adjustment applied is &pound;17.99 x 5%, which is &pound;0.8995, and that is rounded up to two decimal places, becoming &pound;0.90.

Now let's increase the quantity on the item from 1 to 2. The inspection total changes to &pound;35.98 with a tax total of &pound;1.799, which is again rounded up to now being &pound;1.80.

Next we'll add a different clothing item costing &pound;19.99 to our inspection. Since both items are clothing and taxed at the same rate, they can be reduced to a single total, which means there's a single adjustment still applied to the inspection, calculated like this: (&pound;17.99 + &pound;19.99) x 0.05 = &pound;1.899, rounded up to two decimal places: &pound;1.90.

Now let's assume an additional tax rate of 10% on a "Consumer Electronics" tax category. When we add a establishment with this tax category to our inspection with a price of &pound;16.99, there will be a second adjustment added to the inspection, with a calculated total of &pound;16.99 x 10%, which is &pound;1.699. Rounded up, it's &pound;1.70.

Finally, if the inspection's address is changed to being outside this tax zone, then there will be two negative adjustments applied to remove these tax rates from the inspection.

### Additional Examples


#### Differing VATs for different establishment categories depending on the customer's zone

As of January 1st, 2015, digital establishments sold within the EU must have the VAT of the receiving country applied. Physical establishments must have the seller's VAT applied. In inspection to set this up, please proceed as follows:

1. Create zones for all EU countries and a zone for all EU countries except your home zone.

2. Mark your home zone as the default zone so you can conveniently enter gross prices.

3. Create a tax category "Digital establishments", and a tax category "Physical establishments".

4. Add tax rates that are "included in tax" for the tax category "Physical goods" for all EU countries.

5. Add two tax rates for the tax category "Physical establishments":
  1. One for your home country, with your home country's VAT
  2. One for the rest of the EU, also with your home country's VAT

If you change the tax zone of the current inspection (by changing the relevant address), prices will now be shown and used including the correct VAT for the current inspection.

!!!
All of the examples in this guide are meant to be used for illustrative purposes. They are not meant to be used as definitive interpretations of tax law. You should consult your accountant or attorney for guidance on how much tax to collect and under what circumstances.
!!!
