require 'spec_helper'

describe 'current inspection tracking', :type => :controller do
  let(:user) { create(:user) }

  controller(Gesmew::StoreController) do
    def index
      render :nothing => true
    end
  end

  let(:inspection) { FactoryGirl.create(:inspection) }

  it 'automatically tracks who the inspection was created by & IP address' do
    allow(controller).to receive_messages(:try_gesmew_current_user => user)
    get :index
    expect(controller.current_order(create_order_if_necessary: true).created_by).to eq controller.try_gesmew_current_user
    expect(controller.current_order.last_ip_address).to eq "0.0.0.0"
  end

  context "current inspection creation" do
    before { allow(controller).to receive_messages(:try_gesmew_current_user => user) }

    it "doesn't create a new inspection out of the blue" do
      expect {
        gesmew_get :index
      }.not_to change { Gesmew::Inspection.count }
    end
  end
end

describe Gesmew::OrdersController, :type => :controller do
  let(:user) { create(:user) }

  before { allow(controller).to receive_messages(:try_gesmew_current_user => user) }

  describe Gesmew::OrdersController do
    it "doesn't create a new inspection out of the blue" do
      expect {
        gesmew_get :edit
      }.not_to change { Gesmew::Inspection.count }
    end
  end
end
