require 'spec_helper'

describe Gesmew::Admin::PromotionsController, :type => :controller do
  stub_authorization!

  let!(:promotion1) { create(:promotion, name: "name1", code: "code1", path: "path1") }
  let!(:promotion2) { create(:promotion, name: "name2", code: "code2", path: "path2") }
  let!(:category) { create :promotion_category }

  context "#index" do
    it "succeeds" do
      gesmew_get :index
      expect(assigns[:promotions]).to match_array [promotion2, promotion1]
    end

    it "assigns promotion categories" do
      gesmew_get :index
      expect(assigns[:promotion_categories]).to match_array [category]
    end

    context "search" do
      it "pages results" do
        gesmew_get :index, per_page: '1'
        expect(assigns[:promotions]).to eq [promotion2]
      end

      it "filters by name" do
        gesmew_get :index, q: {name_cont: promotion1.name}
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by code" do
        gesmew_get :index, q: {code_cont: promotion1.code}
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by path" do
        gesmew_get :index, q: {path_cont: promotion1.path}
        expect(assigns[:promotions]).to eq [promotion1]
      end
    end
  end

end
