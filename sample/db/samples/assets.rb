Gesmew::Sample.load_sample("products")
Gesmew::Sample.load_sample("variants")

products = {}
products[:ror_baseball_jersey] = Gesmew::Product.find_by_name!("Ruby on Rails Baseball Jersey") 
products[:ror_tote] = Gesmew::Product.find_by_name!("Ruby on Rails Tote")
products[:ror_bag] = Gesmew::Product.find_by_name!("Ruby on Rails Bag")
products[:ror_jr_spaghetti] = Gesmew::Product.find_by_name!("Ruby on Rails Jr. Spaghetti")
products[:ror_mug] = Gesmew::Product.find_by_name!("Ruby on Rails Mug")
products[:ror_ringer] = Gesmew::Product.find_by_name!("Ruby on Rails Ringer T-Shirt")
products[:ror_stein] = Gesmew::Product.find_by_name!("Ruby on Rails Stein")
products[:gesmew_baseball_jersey] = Gesmew::Product.find_by_name!("Gesmew Baseball Jersey")
products[:gesmew_stein] = Gesmew::Product.find_by_name!("Gesmew Stein")
products[:gesmew_jr_spaghetti] = Gesmew::Product.find_by_name!("Gesmew Jr. Spaghetti")
products[:gesmew_mug] = Gesmew::Product.find_by_name!("Gesmew Mug")
products[:gesmew_ringer] = Gesmew::Product.find_by_name!("Gesmew Ringer T-Shirt")
products[:gesmew_tote] = Gesmew::Product.find_by_name!("Gesmew Tote")
products[:gesmew_bag] = Gesmew::Product.find_by_name!("Gesmew Bag")
products[:ruby_baseball_jersey] = Gesmew::Product.find_by_name!("Ruby Baseball Jersey")
products[:apache_baseball_jersey] = Gesmew::Product.find_by_name!("Apache Baseball Jersey")


def image(name, type="jpeg")
  images_path = Pathname.new(File.dirname(__FILE__)) + "images"
  path = images_path + "#{name}.#{type}"
  return false if !File.exist?(path)
  File.open(path)
end

images = {
  products[:ror_tote].master => [
    {
      :attachment => image("ror_tote")
    },
    {
      :attachment => image("ror_tote_back") 
    }
  ],
  products[:ror_bag].master => [
    {
      :attachment => image("ror_bag")
    }
  ],
  products[:ror_baseball_jersey].master => [
    {
      :attachment => image("ror_baseball")
    },
    {
      :attachment => image("ror_baseball_back")
    }
  ],
  products[:ror_jr_spaghetti].master => [
    {
      :attachment => image("ror_jr_spaghetti")
    }
  ],
  products[:ror_mug].master => [
    {
      :attachment => image("ror_mug")
    },
    {
      :attachment => image("ror_mug_back")
    }
  ],
  products[:ror_ringer].master => [
    {
      :attachment => image("ror_ringer")
    },
    {
      :attachment => image("ror_ringer_back")
    }
  ],
  products[:ror_stein].master => [
    {
      :attachment => image("ror_stein")
    },
    {
      :attachment => image("ror_stein_back")
    }
  ],
  products[:apache_baseball_jersey].master => [
    {
      :attachment => image("apache_baseball", "png")
    },
  ],
  products[:ruby_baseball_jersey].master => [
    {
      :attachment => image("ruby_baseball", "png")
    },
  ],
  products[:gesmew_bag].master => [
    {
      :attachment => image("gesmew_bag")
    },
  ],
  products[:gesmew_tote].master => [
    {
      :attachment => image("gesmew_tote_front")
    },
    {
      :attachment => image("gesmew_tote_back") 
    }
  ],
  products[:gesmew_ringer].master => [
    {
      :attachment => image("gesmew_ringer_t")
    },
    {
      :attachment => image("gesmew_ringer_t_back") 
    }
  ],
  products[:gesmew_jr_spaghetti].master => [
    {
      :attachment => image("gesmew_spaghetti")
    }
  ],
  products[:gesmew_baseball_jersey].master => [
    {
      :attachment => image("gesmew_jersey")
    },
    {
      :attachment => image("gesmew_jersey_back") 
    }
  ],
  products[:gesmew_stein].master => [
    {
      :attachment => image("gesmew_stein")
    },
    {
      :attachment => image("gesmew_stein_back") 
    }
  ],
  products[:gesmew_mug].master => [
    {
      :attachment => image("gesmew_mug")
    },
    {
      :attachment => image("gesmew_mug_back") 
    }
  ],
}

products[:ror_baseball_jersey].variants.each do |variant|
  color = variant.option_value("tshirt-color").downcase
  main_image = image("ror_baseball_jersey_#{color}", "png")
  variant.images.create!(:attachment => main_image)
  back_image = image("ror_baseball_jersey_back_#{color}", "png")
  if back_image
    variant.images.create!(:attachment => back_image)
  end
end

images.each do |variant, attachments|
  puts "Loading images for #{variant.product.name}"
  attachments.each do |attachment|
    variant.images.create!(attachment)
  end
end

