$(document).ready ->

  # handle delete click
  $('a.delete-inspector').click ->
    if confirm(Gesmew.translations.are_you_sure_remove)
      del = $(this);
      inspector_id = del.data('inspector-id');
      removeInspector(inspector_id)

inspectorURL = (inspector_id) ->
  url = Gesmew.routes.inspections_api + "/" + inspection_number + "/inspectors/" + inspector_id + ".json"

removeInspector = (inspector_id) ->
  url = inspectorURL(inspector_id)
  $.ajax(
    type: "DELETE"
    url: Gesmew.url(url)
    data:
      token: Gesmew.api_key
  ).done((msg) ->
    window.location.reload(true)
  ).fail (msg) ->
    console.log(msg)
