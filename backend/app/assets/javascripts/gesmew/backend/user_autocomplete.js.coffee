# user autocompletion
$(document).ready ->
  if $("#user_autocomplete_template").length > 0
    window.userTemplate = Handlebars.compile($("#user_autocomplete_template").text())
  return

formatuserResult = (inspector) ->
  userTemplate inspector: inspector

$.fn.userAutocomplete = ->
  @select2
    placeholder: Gesmew.translations.inspector_placeholder
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
        token: Gesmew.api_key

      results: (data) ->
        window.inspectors = data
        results: data

    formatResult: formatuserResult
    formatSelection: (user) ->
        user.name