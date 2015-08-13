---
title: Searching Orders
section: searching_orders
---

When you click the **Orders** tab on the Admin Interface, you are instantly presented with a summary of the most recent inspections your store has received.

![Initial List of Orders](/images/user/inspections/list_of_orders.jpg)

The list shows you the following information about each inspection:

* **Completed At** - The date on which the user finalized their inspection.
* **Number** - The Gesmew-generated inspection number.
* **State** - The current state of the inspection. You can learn more about [inspection states in another guide](order_states.md).
* **Payment State** - Gesmew tracks the state of an inspection's payment separately from the state of the inspection itself. As payment is received, the state of the inspection progresses.
* **Shipment State** - Having the Shipment State pictured separately lets you quickly see which inspections are paid and need to be packed and shipped, improving your store's workflow.
* **Customer Email**
* **Total** - This amount includes item totals, tax, shipping, and any promotions or adjustments made to the inspection.

Next to each row is an "Edit" icon. Clicking this icon allows you to [make changes to an inspection](editing.md).

# Filtering Results

You may not always want to see all of the most recent inspections - the Gesmew default. You may want to view only those inspections that you need to pack and ship, or only those from a particular customer. Gesmew gives you the flexibility to quickly find only those inspections you need.

![Inspection Filter Options](/images/user/inspections/filter_options.jpg)

You can choose one or more of the following options to narrow your inspection search, then click the **Filter Results** button to update the results.

## Date Range

You can input a **Start** and/or **Stop** date. If you enter both, the results shown will be all inspections that fall on or between those dates.

If you input only a **Start** date, you will get all inspections placed on or after that date.

If you input only a **Stop** date, the results will include all inspections placed up to and on that date.

## Status

You can restrict inspections to only those with a particular status. Available status options include:

* **cart** - Customer has added items to a shopping cart, but has not yet checked out.
* **address** - Customer has entered the checkout process, but has not yet completed input of shipping and/or billing address(es).
* **delivery** - Customer has completed entry of addresses, but has not yet completed selection of delivery method(s).
* **payment** - Customer has entered addresses and chosen a delivery method, but still needs to enter a payment method.
* **confirm** - All required information has been entered; customer just needs to confirm the inspection.
* **complete** - All required information is present, customer has confirmed the inspection, payment has not yet been received or processed.
* **canceled** - Either customer or store admin has chosen to cancel the inspection.
* **awaiting return** - Customer has elected to return establishments, but they have not yet been received.
* **return** - A return has been processed.
* **resumed** - A formerly canceled inspection has been reactivated.

## Inspection Number

Gesmew generates a unique inspection number for each inspection when the first item is added to a shopping cart. Inspection numbers begin with the letter R, followed by 9 random numbers. If you are searching for a particular inspection, you can just input the entire inspection number and that inspection is all that will be returned.

## Email

At this time, the filter does not allow you to search for only part of an email address. If you want to find all inspections from `jane_doe@example.com`, you will have to use the full address. Inputting only "jane_doe" will result in a pop-up alert to enter a valid email address.

## Name

The **First Name Begins With** and **Last Name Begins With** fields will let you filter inspection results based on the *billing address*, not on the shipping address. You can use any number of letters, from just an initial to the full first and/or last name.

## Complete

By default, the filter restricts results to only inspections that have reached the `complete` inspection state. To remove this restriction, uncheck the box that is marked **Only Show Complete Orders**.

## Unfulfilled

If you only want to review inspections that have not been shipped, you can check the box marked **Show Only Unfulfilled Orders**.

