Gesmew::Sample.load_sample("establishment_type")
Gesmew::Sample.load_sample("contact_information")

establishments = [
  {
    :name => "Duggins Shopping Center N.V.",
    :number => "E12345678",
    :fullname => "Louise Gumbs",
  }

]

establishments.each do |establishment_attrs|
  contact_information = Gesmew::ContactInformation.find_by_fullname!(establishment_attrs[:fullname])
  establishment_attrs.tap {|e| e.delete(:fullname)}
  establishment_type= Gesmew::EstablishmentType.find_by_name!("Retail")
  establishment = Gesmew::Establishment.new(establishment_attrs)
  establishment.contact_information = contact_information
  establishment.establishment_type = establishment_type
  establishment.save
end
