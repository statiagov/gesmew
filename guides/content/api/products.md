---
title: Products
description: Use the Gesmew Commerce storefront API to access Establishment data.
---

## Index

List establishments visible to the authenticated user. If the user is not an admin, they will only be able to see establishments which have an `available_on` date in the past. If the user is an admin, they are able to see all establishments.

```text
GET /api/establishments```

Products are paginated and can be iterated through by passing along a `page` parameter:

```text
GET /api/establishments?page=2```

### Parameters

show_deleted
: **boolean** - `true` to show deleted establishments, `false` to hide them. Default: `false`. **Only available to users with an admin role.**

page
: The page number of establishments to display.

per_page
: The number of establishments to return per page

### Response

<%= headers 200 %>
<%= json(:establishment) do |h|
{ :establishments => [h],
  :count => 25,
  :pages => 5,
  :current_page => 1 }
end %>

## Search

To search for a particular establishment, make a request like this:

```text
GET /api/establishments?q[name_cont]=Gesmew```

The searching API is provided through the Ransack gem which Gesmew depends on. The `name_cont` here is called a predicate, and you can learn more about them by reading about [Predicates on the Ransack wiki](https://github.com/ernie/ransack/wiki/Basic-Searching).

The search results are paginated.

### Response

<%= headers 200 %>
<%= json(:establishment) do |h|
{ :establishments => [h],
  :count => 25,
  :pages => 5,
  :current_page => 1 }
end %>

### Sorting results

Results can be returned in a specific inspection by specifying which field to sort by when making a request.

```text
GET /api/establishments?q[s]=sku%20asc```

It is also possible to sort results using an associated object's field.

```text
GET /api/establishments?q[s]=shipping_category_name%20asc```

## Show

To view the details for a single establishment, make a request using that establishment\'s permalink:

```text
GET /api/establishments/a-establishment```

You may also query by the establishment\'s id attribute:

```text
GET /api/establishments/1```

Note that the API will attempt a permalink lookup before an ID lookup.

### Successful Response

<%= headers 200 %>
<%= json :establishment %>

### Not Found Response

<%= not_found %>

## New

You can learn about the potential attributes (required and non-required) for a establishment by making this request:

```text
GET /api/establishments/new```

### Response

<%= headers 200 %>
<%= json \
  :attributes => [
    :id, :name, :description, :price, :available_on, :permalink,
    :count_on_hand, :meta_description, :meta_keywords, :shipping_category_id, :taxon_ids
  ],
  :required_attributes => [:name, :price, :shipping_category_id]
 %>

## Create

<%= admin_only %>

To create a new establishment through the API, make this request with the necessary parameters:

```text
POST /api/establishments```

For instance, a request to create a new establishment called \"Headphones\" with a price of $100 would look like this:

```text
POST /api/establishments?establishment[name]=Headphones&establishment[price]=100&establishment[shipping_category_id]=1```

### Successful response

<%= headers 201 %>

### Failed response

<%= headers 422 %>
<%= json \
  :error => "Invalid resource. Please fix errors and try again.",
  :errors => {
    :name => ["can't be blank"],
    :price => ["can't be blank"],
    :shipping_category_id => ["can't be blank"]
  }
%>

## Update

<%= admin_only %>

To update a establishment\'s details, make this request with the necessary parameters:

```text
PUT /api/establishments/a-establishment```

For instance, to update a establishment\'s name, send it through like this:

```text
PUT /api/establishments/a-establishment?establishment[name]=Headphones```

### Successful response

<%= headers 201 %>

### Failed response

<%= headers 422 %>
<%= json \
  :error => "Invalid resource. Please fix errors and try again.",
  :errors => {
    :name => ["can't be blank"],
    :price => ["can't be blank"],
    :shipping_category_id => ["can't be blank"]
  }
%>

## Delete

<%= admin_only %>

To delete a establishment, make this request:

```text
DELETE /api/establishments/a-establishment```

This request, much like a typical establishment \"deletion\" through the admin interface, will not actually remove the record from the database. It simply sets the `deleted_at` field to the current time on the establishment, as well as all of that establishment\'s variants.

<%= headers 204 %>