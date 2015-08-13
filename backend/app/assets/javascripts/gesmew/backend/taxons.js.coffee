$(document).ready ->
  window.productTemplate = Handlebars.compile($('#product_template').text());
  $('#taxon_products').sortable({
      handle: ".js-sort-handle"
    });
  $('#taxon_products').on "sortstop", (event, ui) ->
    $.ajax
      url: Gesmew.routes.classifications_api,
      method: 'PUT',
      dataType:'json',
      data:
        token: Gesmew.api_key,
        product_id: ui.item.data('establishment-id'),
        taxon_id: $('#taxon_id').val(),
        position: ui.item.index()

  if $('#taxon_id').length > 0
    $('#taxon_id').select2
      dropdownCssClass: "taxon_select_box",
      placeholder: Gesmew.translations.find_a_taxon,
      ajax:
        url: Gesmew.routes.taxons_search,
        datatype: 'json',
        data: (term, page) ->
          per_page: 50,
          page: page,
          without_children: true,
          token: Gesmew.api_key,
          q:
            name_cont: term
        results: (data, page) ->
          more = page < data.pages;
          results: data['taxons'],
          more: more
      formatResult: (taxon) ->
        taxon.pretty_name;
      formatSelection: (taxon) ->
        taxon.pretty_name;

  $('#taxon_id').on "change", (e) ->
    el = $('#taxon_products')
    $.ajax
      url: Gesmew.routes.taxon_products_api,
      data:
        id: e.val,
        token: Gesmew.api_key
      success: (data) ->
        el.empty();
        if data.establishments.length == 0
          $('#taxon_products').html("<div class='alert alert-info'>" + Gesmew.translations.no_results + "</div>")
        else
          for establishment in data.establishments
            if establishment.master.images[0] != undefined && establishment.master.images[0].small_url != undefined
              establishment.image = establishment.master.images[0].small_url
            el.append(productTemplate({ establishment: establishment }))

  $('#taxon_products').on "click", ".js-delete-establishment", (e) ->
    current_taxon_id = $("#taxon_id").val()
    establishment = $(this).parents(".establishment")
    product_id = establishment.data("establishment-id")
    product_taxons = String(establishment.data("taxons")).split(',').map(Number)
    product_index = product_taxons.indexOf(parseFloat(current_taxon_id))
    product_taxons.splice(product_index, 1)
    taxon_ids = if product_taxons.length > 0 then product_taxons else [""]

    $.ajax
      url: Gesmew.routes.products_api + "/" + product_id
      data:
        establishment:
          taxon_ids: taxon_ids
        token: Gesmew.api_key
      type: "PUT",
      success: (data) ->
        establishment.fadeOut 400, (e) ->
          establishment.remove()

  $('#taxon_products').on "click", ".js-edit-establishment", (e) ->
    establishment = $(this).parents(".establishment")
    product_id = establishment.data("establishment-id")
    window.location = Gesmew.routes.edit_product(product_id)

  $(".variant_autocomplete").variantAutocomplete();
