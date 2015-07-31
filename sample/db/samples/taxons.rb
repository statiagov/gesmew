Gesmew::Sample.load_sample("taxonomies")
Gesmew::Sample.load_sample("products")

categories = Gesmew::Taxonomy.find_by_name!("Categories")
brands = Gesmew::Taxonomy.find_by_name!("Brand")

products = { 
  :ror_tote => "Ruby on Rails Tote",
  :ror_bag => "Ruby on Rails Bag",
  :ror_mug => "Ruby on Rails Mug",
  :ror_stein => "Ruby on Rails Stein",
  :ror_baseball_jersey => "Ruby on Rails Baseball Jersey",
  :ror_jr_spaghetti => "Ruby on Rails Jr. Spaghetti",
  :ror_ringer => "Ruby on Rails Ringer T-Shirt",
  :gesmew_stein => "Gesmew Stein",
  :gesmew_mug => "Gesmew Mug",
  :gesmew_ringer => "Gesmew Ringer T-Shirt",
  :gesmew_baseball_jersey =>  "Gesmew Baseball Jersey",
  :gesmew_tote => "Gesmew Tote",
  :gesmew_bag => "Gesmew Bag",
  :gesmew_jr_spaghetti => "Gesmew Jr. Spaghetti",
  :apache_baseball_jersey => "Apache Baseball Jersey",
  :ruby_baseball_jersey => "Ruby Baseball Jersey",
}


products.each do |key, name|
  products[key] = Gesmew::Product.find_by_name!(name)
end

taxons = [
  {
    :name => "Categories",
    :taxonomy => categories,
    :position => 0
  },
  {
    :name => "Bags",
    :taxonomy => categories,
    :parent => "Categories",
    :position => 1,
    :products => [
      products[:ror_tote],
      products[:ror_bag],
      products[:gesmew_tote],
      products[:gesmew_bag]
    ]
  },
  {
    :name => "Mugs",
    :taxonomy => categories,
    :parent => "Categories",
    :position => 2,
    :products => [
      products[:ror_mug],
      products[:ror_stein],
      products[:gesmew_stein],
      products[:gesmew_mug]
    ]
  },
  {
    :name => "Clothing",
    :taxonomy => categories,
    :parent => "Categories" 
  },
  {
    :name => "Shirts",
    :taxonomy => categories,
    :parent => "Clothing",
    :position => 0,
    :products => [
      products[:ror_jr_spaghetti],
      products[:gesmew_jr_spaghetti]
    ]
  },
  {
    :name => "T-Shirts",
    :taxonomy => categories,
    :parent => "Clothing" ,
    :products => [
      products[:ror_baseball_jersey],
      products[:ror_ringer],
      products[:apache_baseball_jersey],
      products[:ruby_baseball_jersey],
      products[:gesmew_baseball_jersey],
      products[:gesmew_ringer]
    ],
    :position => 0
  },
  {
    :name => "Brands",
    :taxonomy => brands
  },
  {
    :name => "Ruby",
    :taxonomy => brands,
    :parent => "Brand",
    :products => [
      products[:ruby_baseball_jersey]
    ]
  },
  {
    :name => "Apache",
    :taxonomy => brands,
    :parent => "Brand",
    :products => [
      products[:apache_baseball_jersey]
    ]
  },
  {
    :name => "Gesmew",
    :taxonomy => brands,
    :parent => "Brand",
    :products => [
      products[:gesmew_stein],
      products[:gesmew_mug],
      products[:gesmew_ringer],
      products[:gesmew_baseball_jersey],
      products[:gesmew_tote],
      products[:gesmew_bag],
      products[:gesmew_jr_spaghetti],
    ]
  },
  {
    :name => "Rails",
    :taxonomy => brands,
    :parent => "Brand",
    :products => [
      products[:ror_tote],
      products[:ror_bag],
      products[:ror_mug],
      products[:ror_stein],
      products[:ror_baseball_jersey],
      products[:ror_jr_spaghetti],
      products[:ror_ringer],
    ]
  },
]

taxons.each do |taxon_attrs|
  if taxon_attrs[:parent]
    taxon_attrs[:parent] = Gesmew::Taxon.where(name: taxon_attrs[:parent]).first
    Gesmew::Taxon.create!(taxon_attrs)
  end
end
