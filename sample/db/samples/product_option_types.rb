Gesmew::Sample.load_sample("products")

size = Gesmew::OptionType.find_by_presentation!("Size")
color = Gesmew::OptionType.find_by_presentation!("Color")

ror_baseball_jersey = Gesmew::Product.find_by_name!("Ruby on Rails Baseball Jersey")
ror_baseball_jersey.option_types = [size, color]
ror_baseball_jersey.save!

gesmew_baseball_jersey = Gesmew::Product.find_by_name!("Gesmew Baseball Jersey")
gesmew_baseball_jersey.option_types = [size, color]
gesmew_baseball_jersey.save!
