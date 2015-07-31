$.fn.productAutocomplete = function (options) {
  'use strict';

  // Default options
  options = options || {};
  var multiple = typeof(options.multiple) !== 'undefined' ? options.multiple : true;

  this.select2({
    minimumInputLength: 3,
    multiple: multiple,
    initSelection: function (element, callback) {
      $.get(Gesmew.routes.product_search, {
        ids: element.val().split(','),
        token: Gesmew.api_key
      }, function (data) {
        callback(multiple ? data.products : data.products[0]);
      });
    },
    ajax: {
      url: Gesmew.routes.product_search,
      datatype: 'json',
      data: function (term, page) {
        return {
          q: {
            name_cont: term,
            sku_cont: term
          },
          m: 'OR',
          token: Gesmew.api_key
        };
      },
      results: function (data, page) {
        var products = data.products ? data.products : [];
        return {
          results: products
        };
      }
    },
    formatResult: function (product) {
      return product.name;
    },
    formatSelection: function (product) {
      return product.name;
    }
  });
};

$(document).ready(function () {
  $('.product_picker').productAutocomplete();
});
