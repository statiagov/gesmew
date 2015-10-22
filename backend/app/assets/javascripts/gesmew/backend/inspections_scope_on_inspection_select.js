// This file contains the code for interacting with inspection_scopes on the inspection proccess page
$(document).ready(function () {
    'use strict';

    $('#select_inspection_scope_id').change(function(){
        var inspection_scope_id = $(this).val();
        console.log(inspection_scope_id)
        var inspection_scope = _.find(window.inspection_scopes, function(inspection_scope){
            return inspection_scope.id == inspection_scope_id
        });
        $('#inspection_scope_details').html(inspectionScopeDetailTemplate({inspection_scope: inspection_scope}));
        $('#inspection_scope_details').show();

        $('button.select_inspection_scope').click(selectInspectionScope);
    });
});

selectInspectionScope = function() {
    $('#inspection_scope_details').hide();

    var inspection_scope_id = $('input.inspection_scope_autocomplete').val();
    inspectionScopeApiPost(inspection_scope_id);
    return 1
}

inspectionScopeApiPost = function(inspection_scope_id){
  var url = Gesmew.routes.inspections_api + "/" + inspection_number + '/scopes';
    console.log(url);
    $.ajax({
        type: "POST",
        url: Gesmew.url(url),
        data: {
            scope_id: inspection_scope_id,
            token: Gesmew.api_key
        }
    }).done(function( msg ) {
        window.location.reload(true);
    }).fail(function(msg) {
      console.log(msg)
    });

}
