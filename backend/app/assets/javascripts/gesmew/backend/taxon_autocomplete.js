'use strict';

var set_taxon_select = function(selector){
  if ($(selector).length > 0) {
    $(selector).select2({
      placeholder: Gesmew.translations.taxon_placeholder,
      multiple: true,
      initSelection: function (element, callback) {
        var url = Gesmew.url(Gesmew.routes.taxons_search, {
          ids: element.val(),
          token: Gesmew.api_key
        });
        return $.getJSON(url, null, function (data) {
          return callback(data['taxons']);
        });
      },
      ajax: {
        url: Gesmew.routes.taxons_search,
        datatype: 'json',
        data: function (term, page) {
          return {
            per_page: 50,
            page: page,
            without_children: true,
            q: {
              name_cont: term
            },
            token: Gesmew.api_key
          };
        },
        results: function (data, page) {
          var more = page < data.pages;
          return {
            results: data['taxons'],
            more: more
          };
        }
      },
      formatResult: function (taxon) {
        return taxon.pretty_name;
      },
      formatSelection: function (taxon) {
        return taxon.pretty_name;
      }
    });
  }
}

$(document).ready(function () {
  set_taxon_select('#product_taxon_ids')
});
