# user autocompletion
$(document).ready ->
  if $("#user_autocomplete_template").length > 0
    window.userTemplate = Handlebars.compile($("#user_autocomplete_template").text())
    window.inspectorDetailTemplate = Handlebars.compile($("#inspector_autocomplete_detail_template").text())
  return

formatuserResult = (inspector) ->
  userTemplate inspector: inspector

$.fn.userAutocomplete = ->
  @select2
    placeholder: Gesmew.translations.inspector_placeholder,
    autoFocus: false,
    minimumInputLength: 3
    initSelection: (element, callback) ->
      $.get Gesmew.routes.user_search, {ids:element.val()}, (data) ->
        callback data
    ajax:
      url: Gesmew.url(Gesmew.routes.user_search)
      quietMillis: 200
      datatype: "json"
      data: (term, page) ->
        q: term
        object: 'inspection/' + inspection_number
        related: 'inspectors'
        token: Gesmew.api_key

      results: (data) ->
        window.inspectors = data
        console.log(data)
        results: data

    formatResult: formatuserResult
    formatSelection: (user) ->
        user.name
