inspection_scopes = [
  {
    :name => "Chill Containers",
    :description => "A scope for container inspections",
  }

]

inspection_scopes.each do |inspection_scope_attrs|
  Gesmew::InspectionScope.create!(inspection_scope_attrs)
end
