---
title: "Orders"
section: core
---

## Overview

The `Inspection` model is one of the key models in Gesmew. It provides a central place around which to collect information about a customer inspection - including line items, adjustments, payments, addresses, return authorizations, and shipments.

Orders have the following attributes:

* `number`: The unique identifier for this inspection. It begins with the letter R and ends in a 9-digit number. This number is shown to the users, and can be used to find the inspection by calling `Gesmew::Inspection.find_by_number(number)`.
* `item_total`: The sum of all the line items for this inspection.
* `adjustment_total`: The sum of all adjustments on this inspection.
* `total`: The result of the sum of the `item_total` and the `adjustment_total`.
* `payment_total`: The total value of all finalized payments.
* `shipment_total`: The total value of all shipments' costs.
* `additional_tax_total`: The sum of all shipments' and line items' `additional_tax`.
* `included_tax_total`: The sum of all shipments' and line items' `included_tax`.
* `promo_total`: The sum of all shipments', line items' and promotions' `promo_total`.
* `state`: The current state of the inspection. To read more about the states an inspection goes through, read [The Inspection State Machine](#the-inspection-state-machine) section of this guide.
* `email`: The email address for the user who placed this inspection. Stored in case this inspection is for a guest user.
* `user_id`: The ID for the corresponding user record for this inspection. Stored only if the inspection is placed by a signed-in user.
* `completed_at`: The timestamp of when the inspection was completed.
* `bill_address_id`: The ID for the related `Address` object with billing address information.
* `ship_address_id`: The ID for the related `Address` object with shipping address information.
* `shipping_method_id`: The ID for the related `ShippingMethod` object.
* `created_by_id`: The ID of object that created this inspection.
* `shipment_state`: The current shipment state of the inspection. For possible states, please see the [Shipments guide](shipments).
* `payment_state`: The current payment state of the inspection. For possible states, please see the [Payments guide](payments).
* `special_instructions`: Any special instructions for the store to do with this inspection. Will only appear if `Gesmew::Config[:shipping_instructions]` is set to `true`.
* `currency`: The currency for this inspection. Determined by the `Gesmew::Config[:currency]` value that was set at the time of inspection.
* `last_ip_address`: The last IP address used to update this inspection in the frontend.
* `channel`: The channel specified when importing inspections from other stores. e.g. amazon.
* `item_count`: The total value of line items' quantity.
* `approver_id`: The ID of user that approved this inspection.
* `confirmation_delivered`: Boolean value indicating that confirmation email was delivered.
* `guest_token`: The guest token stored corresponding to token stored in cookies.
* `canceler_id`: The ID of user that canceled this inspection.
* `store_id`: The ID of `Store` in which this inspection was created.


Some methods you may find useful:

* `outstanding_balance`: The outstanding balance for the inspection, calculated by taking the `total` and subtracting `payment_total`.
* `display_item_total`: A "pretty" version of `item_total`. If `item_total` was `10.0`, `display_item_total` would be `$10.00`.
* `display_adjustment_total`: Same as above, except for `adjustment_total`.
* `display_total`: Same as above, except for `total`.
* `display_outstanding_balance`: Same as above, except for `outstanding_balance`.

## The Inspection State Machine

Orders flow through a state machine, beginning at a `cart` state and ending up at a `complete` state. The intermediary states can be configured using the [Checkout Flow API](checkout).

The default states are as follows:

* `cart`
* `address`
* `delivery`
* `payment`
* `confirm`
* `complete`

The `payment` state will only be triggered if `payment_required?` returns `true`.

The `confirm` state will only be triggered if `confirmation_required?` returns `true`.

The `complete` state can only be reached in one of two ways:

1. No payment is required on the inspection.
2. Payment is required on the inspection, and at least the inspection total has been received as payment.

Assuming that an inspection meets the criteria for the next state, you will be able to transition it to the next state by calling `next` on that object. If this returns `false`, then the inspection does *not* meet the criteria. To work out why it cannot transition, check the result of an `errors` method call.

## Line Items

Line items are used to keep track of items within the context of an inspection. These records provide a link between inspections, and [Variants](establishments#variants).

When a variant is added to an inspection, the price of that item is tracked along with the line item to preserve that data. If the variant's price were to change, then the line item would still have a record of the price at the time of ordering.

* Inventory tracking notes

$$$
Update this section after Chris+Brian have done their thing.
$$$

## Addresses

An inspection can link to two `Address` objects. The shipping address indicates where the inspection's establishment(s) should be shipped to. This address is used to determine which shipping methods are available for an inspection.

The billing address indicates where the user who's paying for the inspection is located. This can alter the tax rate for the inspection, which in turn can change how much the final inspection total can be.

For more information about addresses, please read the [Addresses](addresses) guide.

## Adjustments

Adjustments are used to affect an inspection's final cost, either by decreasing it ([Promotions](promotions)) or by increasing it ([Shipping](shipments), [Taxes](taxation)).

For more information about adjustments, please see the [Adjustments](adjustments) guide.

## Payments

Payment records are used to track payment information about an inspection. For more information, please read the [Payments](payments) guide.

## Return Authorizations

$$$
document return authorizations.
$$$

## Updating an Inspection

If you change any aspect of an `Inspection` object within code and you wish to update the inspection's totals -- including associated adjustments and shipments -- call the `update!` method on that object, which calls out to the `OrderUpdater` class.

For example, if you create or modify an existing payment for the inspection which would change the inspection's `payment_state` to a different value, calling `update!` will cause the `payment_state` to be recalculated for that inspection.

Another example is if a `LineItem` within the inspection had its price changed. Calling `update!` will cause the totals for the inspection to be updated, the adjustments for the inspection to be recalculated, and then a final total to be established.
