require 'spec_helper'

describe Gesmew::HomeController, :type => :controller do
  it "provides current user to the searcher class" do
    user = mock_model(Gesmew.user_class, :last_incomplete_gesmew_order => nil, :gesmew_api_key => 'fake')
    allow(controller).to receive_messages :try_gesmew_current_user => user
    expect_any_instance_of(Gesmew::Config.searcher_class).to receive(:current_user=).with(user)
    gesmew_get :index
    expect(response.status).to eq(200)
  end

  context "layout" do
    it "renders default layout" do
      gesmew_get :index
      expect(response).to render_template(layout: 'gesmew/layouts/gesmew_application')
    end

    context "different layout specified in config" do
      before { Gesmew::Config.layout = 'layouts/application' }

      it "renders specified layout" do
        gesmew_get :index
        expect(response).to render_template(layout: 'layouts/application')
      end
    end
  end
end
