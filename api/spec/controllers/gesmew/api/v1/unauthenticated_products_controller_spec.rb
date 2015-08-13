require 'shared_examples/protect_product_actions'
require 'spec_helper'

module Gesmew
  describe Api::V1::ProductsController, :type => :controller do
    render_views

    let!(:establishment) { create(:establishment) }
    let(:attributes) { [:id, :name, :description, :price, :available_on, :slug, :meta_description, :meta_keywords, :taxon_ids] }

    context "without authentication" do
      before { Gesmew::Api::Config[:requires_authentication] = false }

      it "retrieves a list of establishments" do
        api_get :index
        expect(json_response["establishments"].first).to have_attributes(attributes)
        expect(json_response["count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      it_behaves_like "modifying establishment actions are restricted"
    end
  end
end

