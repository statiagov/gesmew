describe Gesmew::Inspection, type: :model do
  let(:user)        {create(:admin_user)}
  let(:inspection)  {create(:inspection)}

  before do
    Gesmew::InspectionUser.create({user:user, inspection: inspection})
  end
end
