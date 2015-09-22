// This file contains the code for interacting with establishments on the inspection proccess page
$(document).ready(function () {
    'use strict';

    $('#select_establishment_id').change(function(){
        var establishment_id = $(this).val();

        var establishment = _.find(window.establishments, function(establishment){
            return establishment.id == establishment_id
        });
        $('#establishment_details').html(establishmentDetailTemplate({establishment: establishment}));
        $('#establishment_details').show();

        $('button.select_establishment').click(selectEstablishment);
    });
});

selectEstablishment = function() {
    $('#establishment_details').hide();

    var establishment_id = $('input.establishment_autocomplete').val();
    establishmentApiPost(establishment_id);
    return 1
}

establishmentApiPost = function(establishment_id){
    var url = Gesmew.routes.inspections_api + "/" + inspection_number + '/establishment';
    console.log(url);
    $.ajax({
        type: "POST",
        url: Gesmew.url(url),
        data: {
          establishment: {
            establishment_id: establishment_id
          },
          token: Gesmew.api_key
        }
    }).done(function( msg ) {
        window.location.reload(true);
    }).fail(function(msg) {
      console.log(msg)
        alert(msg.responseJSON.error)
    });

}
