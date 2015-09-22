cache [I18n.locale, root_object]
node(:number) { |i| i.number }
node(:establishment) { |i| i.establishment.name }
node(:is_completed) { |i| i.completed? }
node(:inspection_steps) { |i| i.inspection_steps }
