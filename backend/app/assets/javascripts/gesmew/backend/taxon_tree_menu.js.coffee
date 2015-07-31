root = exports ? this

root.taxon_tree_menu = (obj, context) ->

  base_url = Gesmew.url(Gesmew.routes.taxonomy_taxons_path)
  admin_base_url = Gesmew.url(Gesmew.routes.admin_taxonomy_taxons_path)
  edit_url = admin_base_url.clone()
  edit_url.setPath(edit_url.path() + '/' + obj.attr("id") + "/edit");

  create:
    label: "<span class='icon icon-plus'></span> " + Gesmew.translations.add,
    action: (obj) -> context.create(obj)
  rename:
    label: "<span class='icon icon-pencil'></span> " + Gesmew.translations.rename,
    action: (obj) -> context.rename(obj)
  remove:
    label: "<span class='icon icon-trash'></span> " + Gesmew.translations.remove,
    action: (obj) -> context.remove(obj)
  edit:
    separator_before: true,
    label: "<span class='icon icon-cog'></span> " + Gesmew.translations.edit,
    action: (obj) -> window.location = edit_url.toString()
