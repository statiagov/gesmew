contact_information = [
  {
    :email => "example@example.com",
    :firstname => "Louise",
    :lastname => "Gumbs",
    :address   => "De Windt weg #5",
    :phone_number => "+5993184701",
  }

]

contact_information.each do |contact_information_attrs|
  Gesmew::ContactInformation.create!(contact_information_attrs)
end
