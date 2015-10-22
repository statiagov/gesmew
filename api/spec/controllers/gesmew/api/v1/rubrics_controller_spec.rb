require 'spec_helper'

module Gesmew
  describe Api::V1::RubricsController, :type => :controller do
    render_views

    let(:scope){create(:inspection_scope, name:'Containers')}
    let(:current_api_user) do
      user = Gesmew.user_class.new(:email => "gesmew@example.com")
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      user.generate_gesmew_api_key!
      user
    end

    before do
      stub_authentication!
    end

    context 'retrieve rubric criteria data' do
      let!(:attributes) {[:id, :points_possible, :criteria]}
      let(:rubric){create(:rubric, context:scope)}
      let(:rubric_params) do
        {
          id:rubric.id,
          title:rubric.title,
          criteria: [
            {
              name: "Temperature",
              points:9,
              description:"The temperature should be...",
            },
            {
              name: "Mold",
              points:10,
              description:"No mold!!",
            }
          ]
        }
      end
      before do
        rubric.update_criteria(rubric_params)
      end
      it 'returns the valid json representation' do
        api_post :show, id: rubric.id
        expect(json_response).to have_attributes(attributes)
        expect(response.status).to  eq(200)
        expect(json_response['criteria'].first['name']).to eq "Temperature"
        expect(json_response['points_possible']).to eq rubric.points_possible
      end
    end
  end
end
