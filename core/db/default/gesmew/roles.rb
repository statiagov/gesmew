Gesmew::Role.where(:name => "admin").first_or_create
Gesmew::Role.where(:name => "user").first_or_create
