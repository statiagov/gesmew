# # user autocompletion
# $(document).ready ->
#   if $("#user_autocomplete_template").length > 0
#     window.userTemplate = Handlebars.compile($("#user_autocomplete_template").text())
#   return
#
# formatuserResult = (user) ->
#   user.image = user.images[0].mini_url  if user["images"][0] isnt `undefined` and user["images"][0].mini_url isnt `undefined`
#   userTemplate user: user
#
# $.fn.userAutocomplete = ->
#   @select2
#     placeholder: Gesmew.translations.inspector_placeholder
#     minimumInputLength: 3
#     initSelection: (element, callback) ->
#       $.get Gesmew.routes.user_search + "/" + element.val(), {}, (data) ->
#         callback data
#     ajax:
#       url: Gesmew.url(Gesmew.routes.user_search)
#       quietMillis: 200
#       datatype: "json"
#       data: (term, page) ->
#         q:
#           product_name_or_sku_cont: term
#         token: Gesmew.api_key
#
#       results: (data, page) ->
#         window.users = data["users"]
#         results: data["users"]
#
#     formatResult: formatuserResult
#     formatSelection: (user) ->
#       if !!user.options_text
#         user.name + " (#{user.options_text})"
#       else
#         user.name
