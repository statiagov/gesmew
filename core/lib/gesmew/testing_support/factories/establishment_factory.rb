FactoryGirl.define do
  factory :establishment, class: Gesmew::Establishment do
    transient do
      type_name "Retail"
      firstname {FFaker::Name.first_name}
      lastname  {FFaker::Name.last_name}
    end

    sequence(:name) {|n| "Establishment #{n}"}
    establishment_type do
        Gesmew::EstablishmentType.find_by(name:type_name) || create(:establishment_type, name:type_name )
    end
    contact_information do
      Gesmew::ContactInformation.find_by(firstname:firstname, lastname:lastname) || create(:contact_information, firstname:firstname, lastname:lastname)
    end
    workers {10}
  end
end
