object @rubric
attributes :id, :points_possible
if @rubric.data.present?
  child :criteria_object => :criteria do
    attributes :id, :points, :description, :name
  end
end
