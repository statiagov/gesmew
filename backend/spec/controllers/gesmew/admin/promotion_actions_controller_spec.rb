require 'spec_helper'

describe Gesmew::Admin::PromotionActionsController, :type => :controller do
  stub_authorization!

  let!(:promotion) { create(:promotion) }

  it "can create a promotion action of a valid type" do
    gesmew_post :create, :promotion_id => promotion.id, :action_type => "Gesmew::Promotion::Actions::CreateAdjustment"
    expect(response).to be_redirect
    expect(response).to redirect_to gesmew.edit_admin_promotion_path(promotion)
    expect(promotion.actions.count).to eq(1)
  end

  it "can not create a promotion action of an invalid type" do
    gesmew_post :create, :promotion_id => promotion.id, :action_type => "Gesmew::InvalidType"
    expect(response).to be_redirect
    expect(response).to redirect_to gesmew.edit_admin_promotion_path(promotion)
    expect(promotion.rules.count).to eq(0)
  end
end
