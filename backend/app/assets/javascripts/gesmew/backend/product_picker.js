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
        callback(multiple ? data.establishments : data.establishments[0]);
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
        var establishments = data.establishments ? data.establishments : [];
        return {
          results: establishments
        };
      }
    },
    formatResult: function (establishment) {
      return establishment.name;
    },
    formatSelection: function (establishment) {
      return establishment.name;
    }
  });
};

$(document).ready(function () {
  $('.product_picker').productAutocomplete();
});
