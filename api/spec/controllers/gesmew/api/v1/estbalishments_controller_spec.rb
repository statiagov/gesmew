require 'spec_helper'
require 'shared_examples/protect_product_actions'

module Gesmew
  describe Api::V1::EstablishmentsController, :type => :controller do
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
        expect(response.status).to  eq(201)
      end
    end

    context 'removing an inspector ' do
      it 'can remove an inspector from an existing inspection' do
        api_delete :destroy, :id => inspector.id
        expect(response.status).to  eq(204)
      end
    end
  end
end
