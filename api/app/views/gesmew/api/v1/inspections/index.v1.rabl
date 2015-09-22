object false
child(@inspections => :inspections) do
  extends "gesmew/api/v1/inspections/inspection"
end
node(:count) { @inspections.count }
node(:current_page) { params[:page] || 1 }
node(:pages) { @inspections.num_pages }
