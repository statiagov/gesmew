require 'spec_helper'

module Gesmew
  describe Api::V1::Inspections::ScopesController, :type => :controller do
    render_views

    let!(:inspection) { create :inspection}
    let!(:scope) { create(:inspection_scope, name: "Container") }
    let!(:rubric){create(:rubric, context:scope)}
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

    context 'adding an inspection scope ' do
      it 'can add an inspection scope to an existing inspection' do
        api_post :create, scope_id: scope.id
        inspection.reload
        expect(inspection.scope).to be_present
        params = {
          association_id: inspection.id,
          association_type: inspection.class.name
        }
        expect(response.status).to  eq(201)
      end
    end

    context 'removing an inspection scope' do
      before do
        api_post :create, scope_id: scope.id
      end
      it 'can remove an inspection scope from an existing inspection' do
        api_delete :destroy, :id => scope.id
        inspection.reload
        expect(inspection.scope).to_not be_present
        params = {
          association_id: inspection.id,
          association_type: inspection.class.name
        }
        expect(response.status).to  eq(204)
      end
    end
  end
end
