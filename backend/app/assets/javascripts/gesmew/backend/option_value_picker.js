$.fn.optionValueAutocomplete = function (options) {
  /* globals Gesmew */
  'use strict';

  // Default options
  options = options || {};
  var multiple = typeof(options.multiple) !== 'undefined' ? options.multiple : true;
  var productSelect = options.productSelect;

  this.select2({
    minimumInputLength: 3,
    multiple: multiple,
    initSelection: function (element, callback) {
      $.get(Gesmew.routes.option_value_search, {
        ids: element.val().split(','),
        token: Gesmew.api_key
      }, function (data) {
        callback(multiple ? data : data[0]);
      });
    },
    ajax: {
      url: Gesmew.routes.option_value_search,
      datatype: 'json',
      data: function (term) {
        var productId = typeof(productSelect) !== 'undefined' ? $(productSelect).select2('val') : null;
        return {
          q: {
            name_cont: term,
            variants_product_id_eq: productId
          },
          token: Gesmew.api_key
        };
      },
      results: function (data) {
        return { results: data };
      }
    },
    formatResult: function (optionValue) {
      return optionValue.name;
    },
    formatSelection: function (optionValue) {
      return optionValue.name;
    }
  });
};
