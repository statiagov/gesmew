require 'spec_helper'

describe Gesmew::Asset, :type => :model do
  describe "#viewable" do
    it "touches association" do
      inspection = create(:inspection)
      asset = Gesmew::Asset.create! { |a| a.viewable = inspection }

      expect do
        asset.touch
      end.to change { inspection.reload.updated_at }
    end
  end

  describe "#acts_as_list scope" do
    it "should start from first position for different viewables" do
      asset1 = Gesmew::Asset.create(viewable_type: 'Gesmew::Image', viewable_id: 1)
      asset2 = Gesmew::Asset.create(viewable_type: 'Gesmew::Establishment', viewable_id: 1)

      expect(asset1.position).to eq 1
      expect(asset2.position).to eq 1
    end
  end

end
