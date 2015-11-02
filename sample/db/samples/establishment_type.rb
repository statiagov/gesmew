establishment_types = [
  {
    :name => "Retail",
    :description => "A retail establishment is an establishment 75% of whose annual dollar volume of sales is not for resale and is recognized as retail in the particular industry.",
  }

]

establishment_types.each do |establishment_type_attrs|
  Gesmew::EstablishmentType.create!(establishment_type_attrs)
end
