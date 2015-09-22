object @inspection
extends "gesmew/api/v1/inspections/inspection"

if lookup_context.find_all("gesmew/api/v1/inspections/#{root_object.state}").present?
  extends "gesmew/api/v1/inspections/#{root_object.state}"
end

node(:establishment) { |i| i.establishment.name }


# Necessary for backend's inspection interface
node :permissions do
  { can_update: current_ability.can?(:update, root_object) }
end
