//= require bootstrap-sprockets
//= require jquery
//= require jquery.cookie
//= require jquery.jstree/jquery.jstree
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require jquery-ui/sortable
//= require jquery-ui/autocomplete
//= require modernizr
//= require underscore-min.js
//= require velocity
//= require gesmew
//= require gesmew/backend/gesmew-select2
//= require_tree .

Gesmew.routes.clear_cache = Gesmew.pathFor('admin/general_settings/clear_cache')
Gesmew.routes.checkouts_api = Gesmew.pathFor('api/v1/checkouts')
Gesmew.routes.classifications_api = Gesmew.pathFor('api/v1/classifications')
Gesmew.routes.option_type_search = Gesmew.pathFor('api/v1/option_types')
Gesmew.routes.option_value_search = Gesmew.pathFor('api/v1/option_values')
Gesmew.routes.orders_api = Gesmew.pathFor('api/v1/orders')
Gesmew.routes.products_api = Gesmew.pathFor('api/v1/products')
Gesmew.routes.product_search = Gesmew.pathFor('admin/search/products')
Gesmew.routes.shipments_api = Gesmew.pathFor('api/v1/shipments')
Gesmew.routes.checkouts_api = Gesmew.pathFor('api/v1/checkouts')
Gesmew.routes.stock_locations_api = Gesmew.pathFor('api/v1/stock_locations')
Gesmew.routes.taxon_products_api = Gesmew.pathFor('api/v1/taxons/products')
Gesmew.routes.taxons_search = Gesmew.pathFor('api/v1/taxons')
Gesmew.routes.user_search = Gesmew.pathFor('admin/search/users')
Gesmew.routes.variants_api = Gesmew.pathFor('api/v1/variants')

Gesmew.routes.edit_product = function(product_id) {
  return Gesmew.pathFor('admin/products/' + product_id + '/edit')
}

Gesmew.routes.payments_api = function(order_id) {
  return Gesmew.pathFor('api/v1/orders/' + order_id + '/payments')
}

Gesmew.routes.stock_items_api = function(stock_location_id) {
  return Gesmew.pathFor('api/v1/stock_locations/' + stock_location_id + '/stock_items')
}
