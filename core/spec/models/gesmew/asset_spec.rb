require 'spec_helper'

describe Gesmew::Asset, :type => :model do
  describe "#viewable" do
    it "touches association" do
      product = create(:custom_product)
      asset = Gesmew::Asset.create! { |a| a.viewable = product.master }

      expect do
        asset.touch
      end.to change { product.reload.updated_at }
    end
  end

  describe "#acts_as_list scope" do
    it "should start from first position for different viewables" do
      asset1 = Gesmew::Asset.create(viewable_type: 'Gesmew::Image', viewable_id: 1)
      asset2 = Gesmew::Asset.create(viewable_type: 'Gesmew::LineItem', viewable_id: 1)

      expect(asset1.position).to eq 1
      expect(asset2.position).to eq 1
    end
  end

end
