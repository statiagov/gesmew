Gesmew::Sample.load_sample("establishment_type")
Gesmew::Sample.load_sample("contact_information")

establishments = [
  {
    :name => "Duggins Shopping Center N.V.",
    :number => "E12345678",
    :fullname => "Louise Gumbs"
  }

]

establishments.each do |establishment_attrs|
  c_attrs = Gesmew::ContactInformation.find_by_fullname!(establishment_attrs.fullname)
  establishment_attrs.delete(:fullname)
  e_attrs = Gesmew::EstablishmentType.find_by_name!("Retail")
  attrs_array = [c_attrs, e_attrs, establishment_attrs]
  default_attrs = attrs_array.inject(&:merge)
  establishment = Gesmew::Establishment.create!(default_attrs)
end
