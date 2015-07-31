$(document).ready(function () {
  'use strict';

  $.each($('td.qty input'), function (i, input) {

    $(input).on('change', function () {

      var id = '#' + $(this).prop('id').replace('_quantity', '_id');

      $.post('/admin/orders/' + $('input#order_number').val() + '/line_items/' + $(id).val(), {
          _method: 'put',
          'line_item[quantity]': $(this).val(),
          token: Gesmew.api_key
        },

        function (resp) {
          $('#order-form-wrapper').html(resp.responseText);
        });
    });
  });
});
