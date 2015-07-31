require 'spec_helper'

describe Gesmew::ProductsController, :type => :controller do
  let!(:product) { create(:product, :available_on => 1.year.from_now) }
  let(:taxon) { create(:taxon) }

  # Regression test for #1390
  it "allows admins to view non-active products" do
    allow(controller).to receive_messages :gesmew_current_user => mock_model(Gesmew.user_class, :has_gesmew_role? => true, :last_incomplete_gesmew_order => nil, :gesmew_api_key => 'fake')
    gesmew_get :show, :id => product.to_param
    expect(response.status).to eq(200)
  end

  it "cannot view non-active products" do
    gesmew_get :show, :id => product.to_param
    expect(response.status).to eq(404)
  end

  it "should provide the current user to the searcher class" do
    user = mock_model(Gesmew.user_class, :last_incomplete_gesmew_order => nil, :gesmew_api_key => 'fake')
    allow(controller).to receive_messages :gesmew_current_user => user
    expect_any_instance_of(Gesmew::Config.searcher_class).to receive(:current_user=).with(user)
    gesmew_get :index
    expect(response.status).to eq(200)
  end

  # Regression test for #2249
  it "doesn't error when given an invalid referer" do
    current_user = mock_model(Gesmew.user_class, :has_gesmew_role? => true, :last_incomplete_gesmew_order => nil, :generate_gesmew_api_key! => nil)
    allow(controller).to receive_messages :gesmew_current_user => current_user
    request.env['HTTP_REFERER'] = "not|a$url"

    # Previously a URI::InvalidURIError exception was being thrown
    expect { gesmew_get :show, :id => product.to_param }.not_to raise_error
  end

  context 'with history slugs present' do
    let!(:product) { create(:product, available_on: 1.day.ago) }

    it 'will redirect with a 301 with legacy url used' do
      legacy_params = product.to_param
      product.name = product.name + " Brand New"
      product.slug = nil
      product.save!
      gesmew_get :show, id: legacy_params
      expect(response.status).to eq(301)
    end

    it 'will redirect with a 301 with id used' do
      product.name = product.name + " Brand New"
      product.slug = nil
      product.save!
      gesmew_get :show, id: product.id
      expect(response.status).to eq(301)
    end

    it "will keep url params on legacy url redirect" do
      legacy_params = product.to_param
      product.name = product.name + " Brand New"
      product.slug = nil
      product.save!
      gesmew_get :show, id: legacy_params, taxon_id: taxon.id
      expect(response.status).to eq(301)
      expect(response.header["Location"]).to include("taxon_id=#{taxon.id}")
    end
  end
end
