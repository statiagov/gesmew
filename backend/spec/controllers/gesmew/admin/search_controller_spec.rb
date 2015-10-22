require 'spec_helper'

describe Gesmew::Admin::SearchController, :type => :controller do
  stub_authorization!
  # Regression test for ernie/ransack#176

  describe "users" do
    let(:user_1) { create(:user, :email => "user_1@example.com", firstname:'Vaughn', lastname:'Sams') }
    let(:user_2) { create(:user, :email => "user_2@example.com", firstname:'Michail', lastname:'Gumbs') }

    it "can find a user by their first or last name "do
      gesmew_xhr_get :users, :q => user_1.firstname
      expect(assigns[:users]).to include(user_1)
      expect(assigns[:users]).to_not include(user_2)
    end

    context "exclude ids" do
      it "excludes inspector_ids" do
        inspection =  create(:inspection)
        inspection.add_inspector(user_1)
        gesmew_xhr_get :users, {:q => user_1.firstname, :object => "inspection/#{inspection.id}", :related => "inspectors" }
        expect(assigns[:users]).to_not include(user_1)
      end
    end
  end

  describe "establishments" do
    let(:establishment_1) { create(:establishment, name:'Duggins')}
    let(:establishment_2) { create(:establishment, name:'Golden Era')}

    it "can find an establishment by it's name" do
      gesmew_xhr_get :establishments,  :q => establishment_1.name
      expect(assigns[:establishments]).to     include(establishment_1)
      expect(assigns[:establishments]).to_not include(establishment_2)
    end
  end

  describe "inspection_scopes" do
    let(:inspection_scope_1) { create(:inspection_scope, name:'Containers')}
    let(:inspection_scope_2) { create(:inspection_scope, name:'Freezers')}

    it "can find a scope by it's name" do
      gesmew_xhr_get :inspection_scopes,  :q => inspection_scope_1.name
      expect(assigns[:inspection_scopes ]).to     include(inspection_scope_1)
      expect(assigns[:inspection_scopes ]).to_not include(inspection_scope_2)
    end
  end
end
