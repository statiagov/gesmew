# inspection_scope autocompletion
$(document).ready ->
  if $("#inspection_scope_autocomplete_template").length > 0
    window.inspectionScopeTemplate = Handlebars.compile($("#inspection_scope_autocomplete_template").text())
    window.inspectionScopeDetailTemplate = Handlebars.compile($("#inspection_scope_autocomplete_detail_template").text())
  return

formatInspectionScopeResult = (inspection_scope) ->
  inspectionScopeTemplate inspection_scope: inspection_scope

$.fn.inspectionScopeAutocomplete = ->
  @select2
    placeholder: Gesmew.translations.inspection_scope_placeholder
    minimumInputLength: 3
    initSelection: (element, callback) ->
      $.get Gesmew.routes.establishment_search, {ids:element.val()}, (data) ->
        callback data
    ajax:
      url: Gesmew.url(Gesmew.routes.inspection_scope_search)
      quietMillis: 200
      datatype: "json"
      data: (term, page) ->
        q: term
        token: Gesmew.api_key

      results: (data) ->
        window.inspection_scopes= data
        results: data

    formatResult: formatInspectionScopeResult
    formatSelection: (inspection_scope) ->
        inspection_scope.name
