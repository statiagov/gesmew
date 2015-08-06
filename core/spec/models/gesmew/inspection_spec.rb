describe Gesmew::Inspection, type: :model do
  let(:user)        {create(:user)}
  let(:inspection)  {create(:inspection)}

  before do
    Gesmew::InspectionUser.create({user:user, inspection: inspection})
  end
end
