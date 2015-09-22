# establishment autocompletion
$(document).ready ->
  if $("#establishment_autocomplete_template").length > 0
    window.establishmentTemplate = Handlebars.compile($("#establishment_autocomplete_template").text())
    window.establishmentDetailTemplate = Handlebars.compile($("#establishment_autocomplete_detail_template").text())
  return

formatEstablishmentResult = (establishment) ->
  establishmentTemplate establishment: establishment

$.fn.establishmentAutocomplete = ->
  @select2
    placeholder: Gesmew.translations.establishment_placeholder
    minimumInputLength: 3
    initSelection: (element, callback) ->
      $.get Gesmew.routes.establishment_search, {ids:element.val()}, (data) ->
        callback data
    ajax:
      url: Gesmew.url(Gesmew.routes.establishment_search)
      quietMillis: 200
      datatype: "json"
      data: (term, page) ->
        q: term
        token: Gesmew.api_key

      results: (data) ->
        window.establishments= data
        results: data

    formatResult: formatEstablishmentResult
    formatSelection: (establishment) ->
        establishment.name
