Gesmew::Sample.load_sample("option_values")
Gesmew::Sample.load_sample("products")

ror_baseball_jersey = Gesmew::Product.find_by_name!("Ruby on Rails Baseball Jersey")
ror_tote = Gesmew::Product.find_by_name!("Ruby on Rails Tote")
ror_bag = Gesmew::Product.find_by_name!("Ruby on Rails Bag")
ror_jr_spaghetti = Gesmew::Product.find_by_name!("Ruby on Rails Jr. Spaghetti")
ror_mug = Gesmew::Product.find_by_name!("Ruby on Rails Mug")
ror_ringer = Gesmew::Product.find_by_name!("Ruby on Rails Ringer T-Shirt")
ror_stein = Gesmew::Product.find_by_name!("Ruby on Rails Stein")
gesmew_baseball_jersey = Gesmew::Product.find_by_name!("Gesmew Baseball Jersey")
gesmew_stein = Gesmew::Product.find_by_name!("Gesmew Stein")
gesmew_jr_spaghetti = Gesmew::Product.find_by_name!("Gesmew Jr. Spaghetti")
gesmew_mug = Gesmew::Product.find_by_name!("Gesmew Mug")
gesmew_ringer = Gesmew::Product.find_by_name!("Gesmew Ringer T-Shirt")
gesmew_tote = Gesmew::Product.find_by_name!("Gesmew Tote")
gesmew_bag = Gesmew::Product.find_by_name!("Gesmew Bag")
ruby_baseball_jersey = Gesmew::Product.find_by_name!("Ruby Baseball Jersey")
apache_baseball_jersey = Gesmew::Product.find_by_name!("Apache Baseball Jersey")

small = Gesmew::OptionValue.where(name: "Small").first
medium = Gesmew::OptionValue.where(name: "Medium").first
large = Gesmew::OptionValue.where(name: "Large").first
extra_large = Gesmew::OptionValue.where(name: "Extra Large").first

red = Gesmew::OptionValue.where(name: "Red").first
blue = Gesmew::OptionValue.where(name: "Blue").first
green = Gesmew::OptionValue.where(name: "Green").first

variants = [
  {
    :product => ror_baseball_jersey,
    :option_values => [small, red],
    :sku => "ROR-00001",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [small, blue],
    :sku => "ROR-00002",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [small, green],
    :sku => "ROR-00003",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [medium, red],
    :sku => "ROR-00004",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [medium, blue],
    :sku => "ROR-00005",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [medium, green],
    :sku => "ROR-00006",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [large, red],
    :sku => "ROR-00007",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [large, blue],
    :sku => "ROR-00008",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [large, green],
    :sku => "ROR-00009",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [extra_large, green],
    :sku => "ROR-00010",
    :cost_price => 17
  },
]

masters = {
  ror_baseball_jersey => {
    :sku => "ROR-001",
    :cost_price => 17,
  },
  ror_tote => {
    :sku => "ROR-00011",
    :cost_price => 17
  },
  ror_bag => {
    :sku => "ROR-00012",
    :cost_price => 21
  },
  ror_jr_spaghetti => {
    :sku => "ROR-00013",
    :cost_price => 17
  },
  ror_mug => {
    :sku => "ROR-00014",
    :cost_price => 11
  },
  ror_ringer => {
    :sku => "ROR-00015",
    :cost_price => 17
  },
  ror_stein => {
    :sku => "ROR-00016",
    :cost_price => 15
  },
  apache_baseball_jersey => {
    :sku => "APC-00001",
    :cost_price => 17
  },
  ruby_baseball_jersey => {
    :sku => "RUB-00001",
    :cost_price => 17
  },
  gesmew_baseball_jersey => {
    :sku => "SPR-00001",
    :cost_price => 17
  },
  gesmew_stein => {
    :sku => "SPR-00016",
    :cost_price => 15
  },
  gesmew_jr_spaghetti => {
    :sku => "SPR-00013",
    :cost_price => 17
  },
  gesmew_mug => {
    :sku => "SPR-00014",
    :cost_price => 11
  },
  gesmew_ringer => {
    :sku => "SPR-00015",
    :cost_price => 17
  },
  gesmew_tote => {
    :sku => "SPR-00011",
    :cost_price => 13
  },
  gesmew_bag => {
    :sku => "SPR-00012",
    :cost_price => 21
  }
}

Gesmew::Variant.create!(variants)

masters.each do |product, variant_attrs|
  product.master.update_attributes!(variant_attrs)
end
