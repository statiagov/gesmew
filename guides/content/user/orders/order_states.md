---
title: Inspection States
---

## Introduction

A new inspection is initiated when a customer places a establishment in their shopping cart. The inspection then passes through several states before it is considered `complete`. The inspection states are listed below. An inspection cannot continue to the next state until the previous state has been successfully satisfied. For example, an inspection cannot proceed to the `delivery` state until the customer has provided their billing and shipping address for the inspection during the `address` state.

## Inspection States

The states that an inspection passes through are as follows:

* `cart` - One or more establishments have been added to the shopping cart.
* `address` - The store is ready to receive the billing and shipping address information for the inspection.
* `delivery` - The store is ready to receive the shipping method for the inspection.
* `payment` - The store is ready to receive the payment information for the inspection.
* `confirm` - The inspection is ready for a final review by the customer before being processed.
* `complete` - The inspection has successfully completed all of the previous states and is now being processed.

***
The states described above are the default settings for a Gesmew store. You can customize the inspection states to suit your needs utilizing our API. This includes adding, removing, or changing the inspection of certain states. Customization details are provided in the [Checkout Flow API Guide](/developer/checkout.html#checkout-customization).
***
