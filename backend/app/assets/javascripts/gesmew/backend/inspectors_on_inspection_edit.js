// This file contains the code for interacting with inspectors on the inspection proccess page
$(document).ready(function () {
    'use strict';

    // handle variant selection, show stock level.
    $('#add_inspector_id').change(function(){
        var inspector_id = $(this).val();

        var inspector = _.find(window.inspectors, function(inspector){
            return inspector.id == inspector_id
        });
        console.log(inspector);
        $('#inspector_details').html(inspectorDetailTemplate({inspector: inspector}));
        $('#inspector_details').show();

        $('button.add_variant').click(addVariant);
    });
});

addVariant = function() {
    $('#stock_details').hide();

    var variant_id = $('input.variant_autocomplete').val();
    var quantity = $("input.quantity[data-variant-id='" + variant_id + "']").val();

    adjustLineItems(order_number, variant_id, quantity);
    return 1
}

adjustLineItems = function(order_number, variant_id, quantity){
    var url = Gesmew.routes.orders_api + "/" + order_number + '/line_items';

    $.ajax({
        type: "POST",
        url: Gesmew.url(url),
        data: {
          line_item: {
            variant_id: variant_id,
            quantity: quantity
          },
          token: Gesmew.api_key
        }
    }).done(function( msg ) {
        window.Gesmew.advanceOrder();
        window.location.reload();
    }).fail(function(msg) {
        alert(msg.responseJSON.message)
    });

}
