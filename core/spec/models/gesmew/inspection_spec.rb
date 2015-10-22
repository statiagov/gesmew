require 'spec_helper'

describe Gesmew::Inspection, type: :model do
  let(:inspector) {create(:admin_user)}
  let(:inspection)  {create(:inspection)}

  describe "#add_inspector" do

    it "should add an inspector to the inspection" do
      inspection.add_inspector(inspector)
      expect(inspection.inspectors.last).to eq(inspector)
    end

    it "should add multipe inspectors given an array" do
      inspection_2 = create(:admin_user)
      array = [inspection_2, inspector]
      inspection.add_inspector(array)
      expect(inspection.inspectors.all).to eq([inspection_2, inspector])
    end
  end

  describe "#remove_inspector" do
    before do
      inspection.add_inspector(inspector)
    end

    it "should remove an inspector from the inspection" do
      inspection.remove_inspector(inspector)
      expect(inspection.inspectors.last).to eq(nil)
      expect(Gesmew.user_class.first).to eq(inspector)
    end
  end

  describe "#ensure_establishment_present" do
    let(:inspection) { create :invalid_inspection }
    before do
      inspection.next
    end

    it 'should have an error message' do
      expect(inspection.errors[:base]).to include(Gesmew.t(:there_is_no_establishment_for_this_inspection))
    end

    it "should have a state of a of 'pending' " do
      expect(inspection.state).to eq('pending')
    end
  end

  describe "#ensure_scope_present" do
    let(:inspection) { create :invalid_inspection }
    before do
      inspection.next
    end

    it 'should have an error message' do
      expect(inspection.errors[:base]).to include(Gesmew.t(:there_is_no_scope_for_this_inspection))
    end

    it "should have a state of a of 'pending' " do
      expect(inspection.state).to eq('pending')
    end
  end



  describe "#ensure_at_least_two_inspectors" do
    let(:inspection) { create :invalid_inspection }
    before do
      inspection.inspectors << inspector
      inspection.next
    end

    it 'should have an error message' do
      expect(inspection.errors[:base]).to include(Gesmew.t(:there_is_no_establishment_for_this_inspection))
    end

    it "should have a state of a of 'pending' " do
      expect(inspection.state).to eq('pending')
    end
  end
end
