require 'spec_helper'

describe Gesmew::TaxonsController, :type => :controller do
  it "should provide the current user to the searcher class" do
    taxon = create(:taxon, :permalink => "test")
    user = mock_model(Gesmew.user_class, :last_incomplete_gesmew_order => nil, :gesmew_api_key => 'fake')
    allow(controller).to receive_messages :gesmew_current_user => user
    expect_any_instance_of(Gesmew::Config.searcher_class).to receive(:current_user=).with(user)
    gesmew_get :show, :id => taxon.permalink
    expect(response.status).to eq(200)
  end
end
