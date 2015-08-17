FactoryGirl.define do
  sequence :user_authentication_token do |n|
    "xxxx#{Time.now.to_i}#{rand(1000)}#{n}xxxxxxxxxxxxx"
  end

  factory :user, class: Gesmew.user_class do
    email { generate(:random_email) }
    login { email }
    password 'secret'
    password_confirmation { password }
    authentication_token { generate(:user_authentication_token) } if Gesmew.user_class.attribute_method? :authentication_token

    transient do
      firstname {FFaker::Name.first_name}
      lastname  {FFaker::Name.last_name}
    end

    contact_information do
      create(:contact_information, firstname:firstname, lastname:lastname)
    end

    factory :admin_user do
      gesmew_roles { [Gesmew::Role.find_by(name: 'admin') || create(:role, name: 'admin')] }
    end

  end
end
