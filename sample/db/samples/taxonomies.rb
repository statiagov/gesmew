taxonomies = [
  { name: "Categories" },
  { name: "Brand" }
]

taxonomies.each do |taxonomy_attrs|
  Gesmew::Taxonomy.create!(taxonomy_attrs)
end
