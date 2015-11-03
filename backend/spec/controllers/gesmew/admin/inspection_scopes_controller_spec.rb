require 'spec_helper'

describe Gesmew::Admin::InspectionScopesController, :type => :controller do
  stub_authorization!
  let!(:inspection_scope1){create(:inspection_scope, name:'Some name', description:'Grading for some name')}
  let!(:inspection_scope2){create(:inspection_scope, name:'Some other name', description:'Grading for some other name')}
  let!(:rubric1) {create(:rubric, context: inspection_scope1)}
  let!(:rubric2) {create(:rubric, context: inspection_scope2)}
  let(:rubric_params1) do
    {
      id:rubric1.id,
      title:rubric1.title,
      criteria: [
        {
          points:9,
          description:"Some description",
          name:"Criteria1",
        },
        {
          points:10,
          description:"Some description",
          name:'Criteria2',
        },
        {
          points:10,
          description:"Some description",
          name:'Criteria3',
        },
        {
          points:10,
          description:"Some description",
          name:'Criteria4',
        },
        {
          points:10,
          description:"Some description",
          name:'Criteria5',
        }
      ]
    }
  end
  let(:rubric_params2) do
    {
      id:rubric2.id,
      title:rubric2.title,
      criteria: [
        {
          points:9,
          description:"Some description",
          name:"Criteria1",
        },
        {
          points:10,
          description:"Some description",
          name:'Criteria2',
        },
        {
          points:10,
          description:"Some description",
          name:'Criteria3',
        }
      ]
    }
  end
  before do
    rubric1.update_criteria(rubric_params1)
    rubric2.update_criteria(rubric_params2)
  end
  context "#index" do
    it "succeeds" do
      gesmew_get :index
      expect(assigns[:inspection_scopes]).to match_array [inspection_scope2, inspection_scope1]
    end
  end

  context "#create" do
    it "redirects to #edit on success" do
      gesmew_post :create, inspection_scope: {name:'Some random name', description:'Some description'}
      expect(response).to redirect_to(redirect_to gesmew.edit_admin_inspection_scope_path(assigns[:inspection_scope]))
    end
  end
end
