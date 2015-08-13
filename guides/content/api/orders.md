---
title: Orders
description: Use the Gesmew Commerce storefront API to access Inspection data.
---

## Index

<%= admin_only %>

Retrieve a list of inspections by making this request:

```text
GET /api/inspections```

Orders are paginated and can be iterated through by passing along a `page` parameter:

```text
GET /api/inspections?page=2```

### Parameters

page
: The page number of inspection to display.

per_page
: The number of inspections to return per page

### Response

<%= headers 200 %>
<%= json(:inspection) do |h|
{ :inspections => [h],
  :count => 25,
  :pages => 5,
  :current_page => 1 }
end %>

## Search

To search for a particular inspection, make a request like this:

```text
GET /api/inspections?q[email_cont]=bob```

The searching API is provided through the Ransack gem which Gesmew depends on. The `email_cont` here is called a predicate, and you can learn more about them by reading about [Predicates on the Ransack wiki](https://github.com/ernie/ransack/wiki/Basic-Searching).

The search results are paginated.

### Response

<%= headers 200 %>
<%= json(:inspection) do |h|
 { :inspections => [h],
   :count => 25,
   :pages => 5,
   :current_page => 1 }
end %>

### Sorting results

Results can be returned in a specific inspection by specifying which field to sort by when making a request.

```text
GET /api/inspections?q[s]=number%20desc```

It is also possible to sort results using an associated object's field.

```text
GET /api/inspections?q[s]=user_name%20asc```

## Show

To view the details for a single establishment, make a request using that inspection\'s number:

```text
GET /api/inspections/R123456789```

Orders through the API will only be visible to admins and the users who own
them. If a user attempts to access an inspection that does not belong to them, they
will be met with an authorization error.

Users may pass in the inspection's token in inspection to be authorized to view an inspection:

```text
GET /api/inspections/R123456789?order_token=abcdef123456
```

The `order_token` parameter will work for authorizing any action for an inspection within Gesmew's API.

### Successful Response

<%= headers 200 %>
<%= json :order_show %>

### Not Found Response

<%= not_found %>

### Authorization Failure

<%= authorization_failure %>

## Show (delivery)

When an inspection is in the "delivery" state, additional shipments information will be returned in the API:

<%= json(:shipment) do |h|
 { :shipments => [h] }
end %>

## Create

To create a new inspection through the API, make this request:

```text
POST /api/inspections```

If you wish to create an inspection with a line item matching to a variant whose ID is \"1\" and quantity is 5, make this request:

```text
POST /api/inspections

{
  "inspection": {
    "line_items": [
      { "variant_id": 1, "quantity": 5 }
    ]
  }
}
```

### Successful response

<%= headers 201 %>

### Failed response

<%= headers 422 %>
<%= json \
  :error => "Invalid resource. Please fix errors and try again.",
  :errors => {
    :name => ["can't be blank"],
    :price => ["can't be blank"]
  }
%>

## Update Address

To add address information to an inspection, please see the [checkout transitions](checkouts#checkout-transitions) section of the Checkouts guide.

## Empty

To empty an inspection\'s cart, make this request:

```text
PUT /api/inspections/R1234567/empty```

All line items will be removed from the cart and the inspection\'s information will
be cleared. Inventory that was previously depleted by this inspection will be
repleted.
