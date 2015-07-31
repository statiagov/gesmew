Gesmew::Sample.load_sample("tax_categories")
Gesmew::Sample.load_sample("shipping_categories")

clothing = Gesmew::TaxCategory.find_by_name!("Clothing")
shipping_category = Gesmew::ShippingCategory.find_by_name!("Default")

default_attrs = {
  description: FFaker::Lorem.paragraph,
  available_on: Time.zone.now
}

products = [
  {
    :name => "Ruby on Rails Tote",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 15.99,
    :eur_price => 14,
  },
  {
    :name => "Ruby on Rails Bag",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 22.99,
    :eur_price => 19,
  },
  {
    :name => "Ruby on Rails Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Ruby on Rails Jr. Spaghetti",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16

  },
  {
    :name => "Ruby on Rails Ringer T-Shirt",
    :shipping_category => shipping_category,
    :tax_category => clothing,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Ruby Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Apache Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Gesmew Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Gesmew Jr. Spaghetti",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Gesmew Ringer T-Shirt",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Gesmew Tote",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 15.99,
    :eur_price => 14,
  },
  {
    :name => "Gesmew Bag",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 22.99,
    :eur_price => 19
  },
  {
    :name => "Ruby on Rails Mug",
    :shipping_category => shipping_category,
    :price => 13.99,
    :eur_price => 12
  },
  {
    :name => "Ruby on Rails Stein",
    :shipping_category => shipping_category,
    :price => 16.99,
    :eur_price => 14
  },
  {
    :name => "Gesmew Stein",
    :shipping_category => shipping_category,
    :price => 16.99,
    :eur_price => 14,
  },
  {
    :name => "Gesmew Mug",
    :shipping_category => shipping_category,
    :price => 13.99,
    :eur_price => 12
  }
]

products.each do |product_attrs|
  eur_price = product_attrs.delete(:eur_price)
  Gesmew::Config[:currency] = "USD"

  default_shipping_category = Gesmew::ShippingCategory.find_by_name!("Default")
  product = Gesmew::Product.create!(default_attrs.merge(product_attrs))
  Gesmew::Config[:currency] = "EUR"
  product.reload
  product.price = eur_price
  product.shipping_category = default_shipping_category
  product.save!
end

Gesmew::Config[:currency] = "USD"
