$(document).ready ->

  # handle delete click
  $('a.remove-establishment').click ->

    swal {
      title: 'Are you sure'
      text: Gesmew.translations.are_you_sure_dissociate_establishment_from_inspection
      type: 'warning'
      showCancelButton: true
      onfirmButtonColor: '#DD6B55'
      confirmButtonText: 'Yes, delete it!'
      cancelButtonText: 'No, cancel please!'
      closeOnConfirm: false
      closeOnCancel: false
      showLoaderOnConfirm: true
    },(isConfirm) ->
      if isConfirm
        del = $(this);
        establishment_id = del.data('establishment-id');
        removeEstablishment(establishment_id)
        swal 'Removed!', 'The association has been removed', 'success'
      else
        swal 'Cancelled', 'Nothing has changed', 'error'
      return

establishmentURL = (establishment_id) ->
  url = Gesmew.routes.inspections_api + "/" + inspection_number + "/establishments/" + establishment_id

removeEstablishment = (establishment_id) ->
  url = establishmentURL(establishment_id)
  $.ajax(
    type: "DELETE"
    url: Gesmew.url(url)
    data:
      token: Gesmew.api_key
  ).done((msg) ->
    window.location.reload(true)
  ).fail (msg) ->
    console.log(msg)
