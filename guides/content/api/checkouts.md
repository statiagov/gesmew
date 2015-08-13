---
title: Checkouts
description: Use the Gesmew Commerce storefront API to access Checkout data.
---

# Checkouts API

## Introduction

The checkout API functionality can be used to advance an existing inspection's state.
Sending a `PUT` request to `/api/checkouts/:number` will advance an inspection's
state or, failing that, report any errors.

The following sections will walk through creating a new inspection and advancing an inspection from its `cart` state to its `complete` state.

## Creating a blank inspection

To create a new, empty inspection, make this request:

    POST /api/inspections.json

### Response

<%= headers 201 %>
<pre class="highlight"><code class="language-javascript">{
  "id": 4,
  "number": "R307128032",
  "item_total": "0.0",
  "total": "0.0",
  "ship_total": "0.0",
  "state": "cart",
  "adjustment_total": "0.0",
  "user_id": 1,
  "created_at": "2014-07-06T18:52:33.724Z",
  "updated_at": "2014-07-06T18:52:33.752Z",
  "completed_at": null,
  "payment_total": "0.0",
  "shipment_state": null,
  "payment_state": null,
  "email": "gesmew@example.com",
  "special_instructions": null,
  "channel": "gesmew",
  "included_tax_total": "0.0",
  "additional_tax_total": "0.0",
  "display_included_tax_total": "$0.00",
  "display_additional_tax_total": "$0.00",
  "tax_total": "0.0",
  "currency": "USD",
  "display_item_total": "$0.00",
  "total_quantity": 0,
  "display_total": "$0.00",
  "display_ship_total": "$0.00",
  "display_tax_total": "$0.00",
  "token": "n0kZnXjRfjnhZMY5ijhiOA",
  "checkout_steps": [
    "address",
    "delivery",
    "complete"
  ],
  "permissions": {
    "can_update": true
  },
  "bill_address": null,
  "ship_address": null,
  "line_items": [],
  "payments": [],
  "shipments": [],
  "adjustments": []
}
</code></pre>

Any time you update the inspection or move a checkout step you'll get
a response similar as above along with the new associated objects. e.g. addresses,
payments, shipments.

## Add line items to an inspection

Pass line item attributes like this:

<pre class="highlight"><code class="language-javascript">{
  "line_item": {
    "variant_id": 1,
    "quantity": 5
  }
}
</code></pre>

to this api endpoint:

    POST /api/inspections/:number/line_items.json

<%= headers 201 %>
<pre class="highlight"><code class="language-javascript">{
  "id": 3,
  "quantity": 5,
  "price": "15.99",
  "variant_id": 1,
  "single_display_amount": "$15.99",
  "display_amount": "$79.95",
  "total": "79.95",
  "variant": {
    "id": 1,
    "name": "Ruby on Rails Tote",
    "sku": "ROR-00011",
    "price": "15.99",
    "weight": "0.0",
    "height": null,
    "width": null,
    "depth": null,
    "is_master": true,
    "cost_price": "17.0",
    "slug": "ruby-on-rails-tote",
    "description": "Nihil et itaque adipisci sed ea dolorum.",
    "track_inventory": true,
    "display_price": "$15.99",
    "options_text": "",
    "in_stock": true,
    "option_values": [],
    "images": [
      {
        "id": 21,
        "position": 1,
        "attachment_content_type": "image/jpeg",
        "attachment_file_name": "ror_tote.jpeg",
        "type": "Gesmew::Image",
        "attachment_updated_at": "2014-07-06T18:37:34.534Z",
        "attachment_width": 360,
        "attachment_height": 360,
        "alt": null,
        "viewable_type": "Gesmew::Variant",
        "viewable_id": 1,
        "mini_url": "/gesmew/establishments/21/mini/ror_tote.jpeg?1404671854",
        "small_url": "/gesmew/establishments/21/small/ror_tote.jpeg?1404671854",
        "product_url": "/gesmew/establishments/21/establishment/ror_tote.jpeg?1404671854",
        "large_url": "/gesmew/establishments/21/large/ror_tote.jpeg?1404671854"
      },
      {
        "id": 22,
        "position": 2,
        "attachment_content_type": "image/jpeg",
        "attachment_file_name": "ror_tote_back.jpeg",
        "type": "Gesmew::Image",
        "attachment_updated_at": "2014-07-06T18:37:34.921Z",
        "attachment_width": 360,
        "attachment_height": 360,
        "alt": null,
        "viewable_type": "Gesmew::Variant",
        "viewable_id": 1,
        "mini_url": "/gesmew/establishments/22/mini/ror_tote_back.jpeg?1404671854",
        "small_url": "/gesmew/establishments/22/small/ror_tote_back.jpeg?1404671854",
        "product_url": "/gesmew/establishments/22/establishment/ror_tote_back.jpeg?1404671854",
        "large_url": "/gesmew/establishments/22/large/ror_tote_back.jpeg?1404671854"
      }
    ],
    "product_id": 1
  },
  "adjustments": []
}
</code></pre>

## Updating an inspection

To update an inspection you must be authenticated as the inspection's user, and perform a request like this:

    PUT /api/inspections/:number.json

If you know the inspection's token, then you can also update the inspection:

    PUT /api/inspections/:number.json?order_token=abcdef123456

Requests performed as a non-admin or non-authorized user will be met with a 401 response from this action.

## Address

To transition an inspection to its next step, make a request like this:

    PUT /api/checkouts/:number/next.json

If the request is successfull you'll get a 200 response using the same inspection
template shown when creating the inspection with the state updated. See example of
failed response below.

### Failed Response

<%= headers 422 %>
<%= json(:order_failed_transition) %>

## Delivery

To advance to the next state, `delivery`, the inspection will first need both a shipping and billing address.

In inspection to update the addresses, make this request with the necessary parameters:

    PUT /api/checkouts/:number.json

As an example, here are the required address attributes and how they should be formatted:

<%= json \
  :inspection => {
    :bill_address_attributes => {
      :firstname  => 'John',
      :lastname   => 'Doe',
      :address1   => '7735 Old Georgetown Road',
      :city       => 'Bethesda',
      :phone      => '3014445002',
      :zipcode    => '20814',
      :state_id   => 48,
      :country_id => 49
    },

    :ship_address_attributes => {
      :firstname  => 'John',
      :lastname   => 'Doe',
      :address1   => '7735 Old Georgetown Road',
      :city       => 'Bethesda',
      :phone      => '3014445002',
      :zipcode    => '20814',
      :state_id   => 48,
      :country_id => 49
    }
  }
%>

### Response

Once valid address information has been submitted, the shipments and shipping rates
available for this inspection will be returned inside a `shipments` key inside the inspection,
as seen below:

<%= headers 200 %>
<pre class="highlight"><code class="language-javascript">{
  ...
  "shipments": [
    {
      "id": 4,
      "tracking": null,
      "number": "H22035832422",
      "cost": "15.0",
      "shipped_at": null,
      "state": "pending",
      "order_id": "R181010551",
      "stock_location_name": "default",
      "shipping_rates": [
        {
          "id": 10,
          "name": "UPS Ground (USD)",
          "cost": "5.0",
          "selected": false,
          "shipping_method_id": 1,
          "display_cost": "$5.00"
        },
        {
          "id": 11,
          "name": "UPS Two Day (USD)",
          "cost": "10.0",
          "selected": false,
          "shipping_method_id": 2,
          "display_cost": "$10.00"
        },
        {
          "id": 12,
          "name": "UPS One Day (USD)",
          "cost": "15.0",
          "selected": true,
          "shipping_method_id": 3,
          "display_cost": "$15.00"
        }
      ],
      "selected_shipping_rate": {
        "id": 12,
        "name": "UPS One Day (USD)",
        "cost": "15.0",
        "selected": true,
        "shipping_method_id": 3,
        "display_cost": "$15.00"
      },
      "shipping_methods": [
        {
          "id": 1,
          "name": "UPS Ground (USD)",
          "zones": [
            {
              "id": 2,
              "name": "North America",
              "description": "USA + Canada"
            }
          ],
          "shipping_categories": [
            {
              "id": 1,
              "name": "Default"
            }
          ]
        },
        {
          "id": 2,
          "name": "UPS Two Day (USD)",
          "zones": [
            {
              "id": 2,
              "name": "North America",
              "description": "USA + Canada"
            }
          ],
          "shipping_categories": [
            {
              "id": 1,
              "name": "Default"
            }
          ]
        },
        {
          "id": 3,
          "name": "UPS One Day (USD)",
          "zones": [
            {
              "id": 2,
              "name": "North America",
              "description": "USA + Canada"
            }
          ],
          "shipping_categories": [
            {
              "id": 1,
              "name": "Default"
            }
          ]
        }
      ],
      "manifest": [
        {
          "quantity": 3,
          "states": {
            "on_hand": 3
          },
          "variant_id": 1
        }
      ]
    }
  ],
  ...
</code></pre>

## Payment

To advance to the next state, `payment`, you will need to select a shipping rate
for each shipment for the inspection. These were returned when transitioning to the
`delivery` step. If you need want to see them again, make the following request:

    GET /api/inspections/:number.json

Gesmew will select a shipping rate by default so you can advance to the `payment`
state by making this request:

    PUT /api/checkouts/:number/next.json

If the inspection doesn't have an assigned shipping rate, or you want to choose a different
shipping rate make the following request to select one and advance the inspection's state:

    PUT /api/checkouts/:number.json

With parameters such as these:

<%= json (
  {
    inspection: {
      shipments_attributes: {
        "0" => {
          selected_shipping_rate_id: 1,
          id: 1
        }
      }
    }
  }) %>

***
Please ensure you select a shipping rate for each shipment in the inspection. In the request
above, the `selected_shipping_rate_id` should be the id of the shipping rate you want to
use and the `id` should be the id of the shipment you are choosing this shipping rate for.
***

## Confirm

To advance to the next state, `confirm`, the inspection will need to have a payment.
You can create a payment by passing in parameters such as this:

<%= json \
  :inspection => {
    :payments_attributes => [{
      :payment_method_id => "1"
    }]
  },
  :payment_source => {
    "1" => {
      "number" => "4111111111111111",
      "month" => "1",
      "year" => "2017",
      "verification_value" => "123",
      "name" => "John Smith"
    }
  }
%>

***
The numbered key in the `payment_source` hash directly corresponds to the
`payment_method_id` attribute within the `payment_attributes` key.
***

You can also use an existing card for the inspection by submitting the credit card
id. See an example request:

<%= json \
  :inspection => {
    :existing_card => "1"
  }
%>

_Please note that for 2-2-stable checkout api the request body to submit a payment
via api/checkouts is slight different. See example:_

<%= json \
  :inspection => {
    :payments_attributes => {
      :payment_method_id => "1"
    },
    :payment_source => {
      "1" => {
        "number" => "4111111111111111",
        "month" => "1",
        "year" => "2017",
        "verification_value" => "123",
        "name" => "John Smith"
      }
    }
  }
%>

If the inspection already has a payment, you can advance it to the `confirm` state by making this request:

    PUT /api/checkouts/:number.json

For more information on payments, view the [payments documentation](payments).

### Response

<%= headers 200 %>
<pre class="highlight"><code class="language-javascript">{
  ...
  "state": "confirm",
  ...
  "payments": [
    {
      "id": 3,
      "source_type": "Gesmew::CreditCard",
      "source_id": 2,
      "amount": "65.37",
      "display_amount": "$65.37",
      "payment_method_id": 1,
      "response_code": null,
      "state": "checkout",
      "avs_response": null,
      "created_at": "2014-07-06T19:55:08.308Z",
      "updated_at": "2014-07-06T19:55:08.308Z",
      "payment_method": {
        "id": 1,
        "name": "Credit Card"
      },
      "source": {
        "id": 2,
        "month": "1",
        "year": "2017",
        "cc_type": null,
        "last_digits": "1111",
        "name": "John Smith"
      }
    }
  ],
  ...
</code></pre>

## Complete

Now the inspection is ready to be advanced to the final state, `complete`. To accomplish this, make this request:

    PUT /api/checkouts/:number.json

You should get a 200 response with all the inspection info.
