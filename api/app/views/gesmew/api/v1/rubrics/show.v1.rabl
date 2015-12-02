object @rubric
attributes :id, :criteria_count
if @rubric.data.present?
  child :criteria_object => :criteria do
    attributes :id, :description, :name
  end
end
