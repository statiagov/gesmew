Gesmew::Sample.load_sample("inspection_scopes")

rubrics = [
  {
    scope_name: "Chill Containers",
    criteria: [
        {
          points:9,
          description:"The temperature of the container must be below 0 degrees Celuis. ",
          name:"Temperature",
        },
        {
          points:10,
          description:"There should be no loose cargo.",
          name:'Storage',
        }
    ]
  }
]

rubrics.each do |rubric_attrs|
  rubric = Gesmew::Rubric.create!
  rubric.context = Gesmew::InspectionScope.find_by_name(rubric_attrs[:scope_name])
  rubric.save
  params = {
    id:rubric.id,
    criteria:rubric_attrs[:criteria]
  }
  rubric.update_criteria(params)
end
