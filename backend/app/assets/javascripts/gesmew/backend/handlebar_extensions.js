//= require handlebars
Handlebars.registerHelper("t", function(key) {
  if (Gesmew.translations[key]) {
    return Gesmew.translations[key]
  } else {
    console.error("No translation found for " + key + ". Does it exist within gesmew/admin/shared/_translations.html.erb?")
  }
});

