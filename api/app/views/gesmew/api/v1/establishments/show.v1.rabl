object @establishment
cache [I18n.locale, @current_user_roles.include?('admin'), current_currency, root_object]

attributes *establishment_attributes

node(:establishment_type) { |e| e.establishment_type.name}

child :inspections => :inspections do
  extends "gesmew/api/v1/inspections/show"
end
