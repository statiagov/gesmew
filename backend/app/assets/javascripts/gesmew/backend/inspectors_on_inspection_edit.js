// This file contains the code for interacting with inspectors on the inspection proccess page
$(document).ready(function () {
    'use strict';

    $('#add_inspector_id').change(function(){
        var inspector_id = $(this).val();

        var inspector = _.find(window.inspectors, function(inspector){
            return inspector.id == inspector_id
        });
        $('#inspector_details').html(inspectorDetailTemplate({inspector: inspector}));
        $('#inspector_details').show();

        $('button.add_inspector').click(addInspector);
    });
});

addInspector = function() {
    $('#inspector_details').hide();

    var inspector_id = $('input.user_autocomplete').val();
    inspectorApiPost(inspector_id);
    return 1
}

inspectorApiPost = function(inspector_id){
    var url = Gesmew.routes.inspections_api + "/" + inspection_number + '/inspectors';
    console.log(url);
    $.ajax({
        type: "POST",
        url: Gesmew.url(url),
        data: {
          inspector: {
            inspector_id: inspector_id
          },
          token: Gesmew.api_key
        }
    }).done(function( msg ) {
        window.location.reload();
    }).fail(function(msg) {
      console.log(msg)
        alert(msg.responseJSON.error)
    });

}
