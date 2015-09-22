describe Gesmew::Inspection, type: :model do
  let(:inspector) {create(:user)}
  let(:inspection)  {create(:inspection)}

  context "#add_inspector" do
    it "should add an inspector to the inspection" do
      inspection.add_inspector(inspector)
      expect(inspection.inspectors.last).to eq(inspector)
    end
  end

  context "#remove_inspector" do
    before do
      inspection.add_inspector(inspector)
    end
    it "should remove an inspector from the inspection" do
      inspection.remove_inspector(inspector)
      expect(inspection.inspectors.last).to eq(nil)
      expect(Gesmew.user_class.first).to eq(inspector)
    end
  end

end
