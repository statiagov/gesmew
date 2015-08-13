Gesmew::Sample.load_sample("establishments")
Gesmew::Sample.load_sample("variants")

establishments = {}
establishments[:ror_baseball_jersey] = Gesmew::Establishment.find_by_name!("Ruby on Rails Baseball Jersey") 
establishments[:ror_tote] = Gesmew::Establishment.find_by_name!("Ruby on Rails Tote")
establishments[:ror_bag] = Gesmew::Establishment.find_by_name!("Ruby on Rails Bag")
establishments[:ror_jr_spaghetti] = Gesmew::Establishment.find_by_name!("Ruby on Rails Jr. Spaghetti")
establishments[:ror_mug] = Gesmew::Establishment.find_by_name!("Ruby on Rails Mug")
establishments[:ror_ringer] = Gesmew::Establishment.find_by_name!("Ruby on Rails Ringer T-Shirt")
establishments[:ror_stein] = Gesmew::Establishment.find_by_name!("Ruby on Rails Stein")
establishments[:gesmew_baseball_jersey] = Gesmew::Establishment.find_by_name!("Gesmew Baseball Jersey")
establishments[:gesmew_stein] = Gesmew::Establishment.find_by_name!("Gesmew Stein")
establishments[:gesmew_jr_spaghetti] = Gesmew::Establishment.find_by_name!("Gesmew Jr. Spaghetti")
establishments[:gesmew_mug] = Gesmew::Establishment.find_by_name!("Gesmew Mug")
establishments[:gesmew_ringer] = Gesmew::Establishment.find_by_name!("Gesmew Ringer T-Shirt")
establishments[:gesmew_tote] = Gesmew::Establishment.find_by_name!("Gesmew Tote")
establishments[:gesmew_bag] = Gesmew::Establishment.find_by_name!("Gesmew Bag")
establishments[:ruby_baseball_jersey] = Gesmew::Establishment.find_by_name!("Ruby Baseball Jersey")
establishments[:apache_baseball_jersey] = Gesmew::Establishment.find_by_name!("Apache Baseball Jersey")


def image(name, type="jpeg")
  images_path = Pathname.new(File.dirname(__FILE__)) + "images"
  path = images_path + "#{name}.#{type}"
  return false if !File.exist?(path)
  File.open(path)
end

images = {
  establishments[:ror_tote].master => [
    {
      :attachment => image("ror_tote")
    },
    {
      :attachment => image("ror_tote_back") 
    }
  ],
  establishments[:ror_bag].master => [
    {
      :attachment => image("ror_bag")
    }
  ],
  establishments[:ror_baseball_jersey].master => [
    {
      :attachment => image("ror_baseball")
    },
    {
      :attachment => image("ror_baseball_back")
    }
  ],
  establishments[:ror_jr_spaghetti].master => [
    {
      :attachment => image("ror_jr_spaghetti")
    }
  ],
  establishments[:ror_mug].master => [
    {
      :attachment => image("ror_mug")
    },
    {
      :attachment => image("ror_mug_back")
    }
  ],
  establishments[:ror_ringer].master => [
    {
      :attachment => image("ror_ringer")
    },
    {
      :attachment => image("ror_ringer_back")
    }
  ],
  establishments[:ror_stein].master => [
    {
      :attachment => image("ror_stein")
    },
    {
      :attachment => image("ror_stein_back")
    }
  ],
  establishments[:apache_baseball_jersey].master => [
    {
      :attachment => image("apache_baseball", "png")
    },
  ],
  establishments[:ruby_baseball_jersey].master => [
    {
      :attachment => image("ruby_baseball", "png")
    },
  ],
  establishments[:gesmew_bag].master => [
    {
      :attachment => image("gesmew_bag")
    },
  ],
  establishments[:gesmew_tote].master => [
    {
      :attachment => image("gesmew_tote_front")
    },
    {
      :attachment => image("gesmew_tote_back") 
    }
  ],
  establishments[:gesmew_ringer].master => [
    {
      :attachment => image("gesmew_ringer_t")
    },
    {
      :attachment => image("gesmew_ringer_t_back") 
    }
  ],
  establishments[:gesmew_jr_spaghetti].master => [
    {
      :attachment => image("gesmew_spaghetti")
    }
  ],
  establishments[:gesmew_baseball_jersey].master => [
    {
      :attachment => image("gesmew_jersey")
    },
    {
      :attachment => image("gesmew_jersey_back") 
    }
  ],
  establishments[:gesmew_stein].master => [
    {
      :attachment => image("gesmew_stein")
    },
    {
      :attachment => image("gesmew_stein_back") 
    }
  ],
  establishments[:gesmew_mug].master => [
    {
      :attachment => image("gesmew_mug")
    },
    {
      :attachment => image("gesmew_mug_back") 
    }
  ],
}

establishments[:ror_baseball_jersey].variants.each do |variant|
  color = variant.option_value("tshirt-color").downcase
  main_image = image("ror_baseball_jersey_#{color}", "png")
  variant.images.create!(:attachment => main_image)
  back_image = image("ror_baseball_jersey_back_#{color}", "png")
  if back_image
    variant.images.create!(:attachment => back_image)
  end
end

images.each do |variant, attachments|
  puts "Loading images for #{variant.establishment.name}"
  attachments.each do |attachment|
    variant.images.create!(attachment)
  end
end

