object @rubric
attributes :id, :points_possible
child :criteria_object => :criteria do
  attributes :id, :points, :description, :name
  node :score do
    0
  end
end
