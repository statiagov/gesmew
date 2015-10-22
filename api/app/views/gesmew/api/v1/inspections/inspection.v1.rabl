cache [I18n.locale, root_object]
attributes :number, :state
node(:inspected_at){|i| i.inspected_at.to_s}
node(:establishment) { |i| i.establishment.name if i.establishment.present?}

node(:is_completed) { |i| i.completed? }
node(:inspection_steps) { |i| i.inspection_steps }
