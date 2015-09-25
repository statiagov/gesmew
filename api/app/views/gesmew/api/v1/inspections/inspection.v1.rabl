cache [I18n.locale, root_object]
attributes :number, :state
if @inspection.establishment.present?
  node(:establishment) { |i| i.establishment.name}
end
node(:is_completed) { |i| i.completed? }
node(:inspection_steps) { |i| i.inspection_steps }
