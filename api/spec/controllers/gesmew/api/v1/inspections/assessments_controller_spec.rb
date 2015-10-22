require 'spec_helper'

module Gesmew
  describe Api::V1::Inspections::AssessmentsController, :type => :controller do
    render_views

    let(:scope){create(:inspection_scope, name:'Containers')}
    let!(:inspection) {create(:inspection, scope: scope)}
    let(:current_api_user) do
      user = Gesmew.user_class.new(:email => "gesmew@example.com")
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      user.generate_gesmew_api_key!
      user
    end
    let(:resource_scoping) { { :inspection_id => inspection.to_param } }

    before do
      stub_authentication!
    end

    context 'retrieve assessement criteria data' do
      let(:rubric){create(:rubric, context:scope)}
      let(:association){rubric.associate_with(inspection, scope)}
      before do
         rubric.data = [
          {
            points: 10,
            description: 'Some Description',
            id: 'id1'
          },
          {
            points: 10,
            description: 'Some Description',
            id: 'id2'
          }
        ]
        rubric.save
      end
      it 'returns the valid json representation' do
        api_get :index , association: {association_id: association.association_id, association_type: association.association_type}
        inspection.reload
        expect(inspection.scope).to be_present
        expect(response.status).to  eq(201)
      end
    end

    context 'removing an inspection scope' do
      before do
        inspection.update_attributes(scope:scope)
      end
      it 'can remove an inspection scope from an existing inspection' do
        api_delete :destroy, :id => scope.id
        inspection.reload
        expect(inspection.scope).to_not be_present
        expect(response.status).to  eq(204)
      end
    end
  end
end
