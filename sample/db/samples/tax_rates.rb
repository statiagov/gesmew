north_america = Gesmew::Zone.find_by_name!("North America")
clothing = Gesmew::TaxCategory.find_by_name!("Clothing")
tax_rate = Gesmew::TaxRate.create(
  :name => "North America",
  :zone => north_america, 
  :amount => 0.05,
  :tax_category => clothing)
tax_rate.calculator = Gesmew::Calculator::DefaultTax.create!
tax_rate.save!
