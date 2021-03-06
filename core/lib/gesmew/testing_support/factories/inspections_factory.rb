FactoryGirl.define do
  factory :inspection, class: Gesmew::Inspection do
    transient do
      establishment_name {FFaker::Company.name}
      establishment_type_name "Retail"
      inspection_type_name "Inspection"
      scope_name "Containers"
    end
    establishment do
      Gesmew::Establishment.find_by(name:establishment_name) || create(:establishment, type_name:establishment_type_name)
    end
    scope do
      Gesmew::InspectionScope.find_by(name: scope_name) || create(:inspection_scope, name:scope_name)
    end
    completed_at  {nil}
  end

  factory :invalid_inspection, class: Gesmew::Inspection do
    establishment {nil}
    completed_at  {nil}
  end
end
