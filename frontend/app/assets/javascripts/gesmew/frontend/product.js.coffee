Gesmew.ready ($) ->
  Gesmew.addImageHandlers = ->
    thumbnails = ($ '#establishment-images ul.thumbnails')
    ($ '#main-image').data 'selectedThumb', ($ '#main-image img').attr('src')
    thumbnails.find('li').eq(0).addClass 'selected'
    thumbnails.find('a').on 'click', (event) ->
      ($ '#main-image').data 'selectedThumb', ($ event.currentTarget).attr('href')
      ($ '#main-image').data 'selectedThumbId', ($ event.currentTarget).parent().attr('id')
      thumbnails.find('li').removeClass 'selected'
      ($ event.currentTarget).parent('li').addClass 'selected'
      false

    thumbnails.find('li').on 'mouseenter', (event) ->
      ($ '#main-image img').attr 'src', ($ event.currentTarget).find('a').attr('href')

    thumbnails.find('li').on 'mouseleave', (event) ->
      ($ '#main-image img').attr 'src', ($ '#main-image').data('selectedThumb')

  Gesmew.showVariantImages = (variantId) ->
    ($ 'li.vtmb').hide()
    ($ 'li.tmb-' + variantId).show()
    currentThumb = ($ '#' + ($ '#main-image').data('selectedThumbId'))
    if not currentThumb.hasClass('vtmb-' + variantId)
      thumb = ($ ($ '#establishment-images ul.thumbnails li:visible.vtmb').eq(0))
      thumb = ($ ($ '#establishment-images ul.thumbnails li:visible').eq(0)) unless thumb.length > 0
      newImg = thumb.find('a').attr('href')
      ($ '#establishment-images ul.thumbnails li').removeClass 'selected'
      thumb.addClass 'selected'
      ($ '#main-image img').attr 'src', newImg
      ($ '#main-image').data 'selectedThumb', newImg
      ($ '#main-image').data 'selectedThumbId', thumb.attr('id')

  Gesmew.updateVariantPrice = (variant) ->
    variantPrice = variant.data('price')
    ($ '.price.selling').text(variantPrice) if variantPrice
  radios = ($ '#establishment-variants input[type="radio"]')

  if radios.length > 0
    selectedRadio = ($ '#establishment-variants input[type="radio"][checked="checked"]')
    Gesmew.showVariantImages selectedRadio.attr('value')
    Gesmew.updateVariantPrice selectedRadio

  Gesmew.addImageHandlers()

  radios.click (event) ->
    Gesmew.showVariantImages @value
    Gesmew.updateVariantPrice ($ this)
