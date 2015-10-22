require 'spec_helper'

module Gesmew
  describe Api::V1::Inspections::EstablishmentsController, :type => :controller do
    render_views

    let!(:inspection) { create :inspection, establishment: nil}
    let!(:establishment) { create(:establishment, name: "Mikey Company") }
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

    context 'adding an establishment ' do
      it 'can add an establishment to an existing inspection' do
        api_post :create, :establishment => { establishment_id: establishment.id }
        inspection.reload
        expect(inspection.establishment).to be_present
        expect(response.status).to  eq(201)
      end
    end

    context 'removing an establishment' do
      before do
        inspection.update_attributes(establishment:establishment)
      end
      it 'can remove an establishment from an existing inspection' do
        api_delete :destroy, :id => establishment.id
        inspection.reload
        expect(inspection.establishment).to_not be_present
        expect(response.status).to  eq(204)
      end
    end
  end
end
