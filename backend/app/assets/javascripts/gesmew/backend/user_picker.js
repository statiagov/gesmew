$.fn.userAutocomplete = function () {
  'use strict';

  this.select2({
    minimumInputLength: 1,
    multiple: true,
    initSelection: function (element, callback) {
      $.get(Gesmew.routes.user_search, {
        ids: element.val()
      }, function (data) {
        callback(data);
      });
    },
    ajax: {
      url: Gesmew.routes.user_search,
      datatype: 'json',
      data: function (term) {
        return {
          q: term,
          token: Gesmew.api_key
        };
      },
      results: function (data) {
        return {
          results: data
        };
      }
    },
    formatResult: function (user) {
      return user.email;
    },
    formatSelection: function (user) {
      return user.email;
    }
  });
};

$(document).ready(function () {
  $('.user_picker').userAutocomplete();
});