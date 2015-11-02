//= require bootstrap-sprockets
//= require jquery
//= require jquery.cookie
//= require jquery.jstree/jquery.jstree
//= require jquery_ujs
//= require underscore-min.js
//= require sweetalert
//= require jquery-ui/datepicker
//= require jquery-ui/sortable
//= require jquery-ui/autocomplete
//= require bootstrap-wysihtml5
//= require gesmew/backend/gesmew-select2
//= require react_integration
//= require react_bundle
//= require modernizr
//= require velocity
//= require gesmew


//= require_tree .

Gesmew.routes.clear_cache = Gesmew.pathFor('admin/general_settings/clear_cache')
Gesmew.routes.checkouts_api = Gesmew.pathFor('api/v1/checkouts')
Gesmew.routes.classifications_api = Gesmew.pathFor('api/v1/classifications')
Gesmew.routes.option_type_search = Gesmew.pathFor('api/v1/option_types')
Gesmew.routes.option_value_search = Gesmew.pathFor('api/v1/option_values')
Gesmew.routes.inspections_api = Gesmew.pathFor('api/v1/inspections')
Gesmew.routes.establishments_api = Gesmew.pathFor('api/v1/establishments')
Gesmew.routes.establishment_search = Gesmew.pathFor('admin/search/establishments')
Gesmew.routes.shipments_api = Gesmew.pathFor('api/v1/shipments')
Gesmew.routes.checkouts_api = Gesmew.pathFor('api/v1/checkouts')
Gesmew.routes.stock_locations_api = Gesmew.pathFor('api/v1/stock_locations')
Gesmew.routes.taxon_products_api = Gesmew.pathFor('api/v1/taxons/establishments')
Gesmew.routes.taxons_search = Gesmew.pathFor('api/v1/taxons')
Gesmew.routes.user_search = Gesmew.pathFor('admin/search/users')
Gesmew.routes.variants_api = Gesmew.pathFor('api/v1/variants')
Gesmew.routes.inspection_scope_search = Gesmew.pathFor('admin/search/inspection_scopes')
Gesmew.routes.edit_establishment = function(establishment_id) {
  return Gesmew.pathFor('admin/establishments/' + establishment_id + '/edit')
}
