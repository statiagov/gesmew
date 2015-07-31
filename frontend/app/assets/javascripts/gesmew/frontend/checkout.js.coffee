//= require jquery.payment
//= require_self
//= require gesmew/frontend/checkout/address
//= require gesmew/frontend/checkout/payment

Gesmew.disableSaveOnClick = ->
  ($ 'form.edit_order').submit ->
    ($ this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass 'disabled'

Gesmew.ready ($) ->
  Gesmew.Checkout = {}
