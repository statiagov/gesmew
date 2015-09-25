require 'spec_helper'
require 'gesmew/testing_support/bar_ability'

module Gesmew
  describe Api::V1::InspectionsController, :type => :controller do
    render_views

    let!(:inspection) { create(:inspection) }

    let(:current_api_user) do
      user = Gesmew.user_class.new(:email => "gesmew@example.com")
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      user.generate_gesmew_api_key!
      user
    end

    before do
      stub_authentication!
    end

    context "the current api user is authenticated" do
      let(:inspection) { create(:inspection)}

      it "can view all inspections" do
        api_get :index

        expect(response.status).to eq(200)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["inspections"].length).to eq(1)
        expect(json_response["inspections"].first["number"]).to eq(inspection.number)
      end

      it "can filter the returned results" do
        api_get :index, q: {completed_at_not_null: 1}

        expect(response.status).to eq(200)
        expect(json_response["inspections"].length).to eq(0)
      end

      it "returns inspections in reverse chronological inspection by completed_at" do
        inspection.update_columns completed_at: Time.now

        inspection2 = create(:inspection, completed_at: Time.now - 1.day)
        expect(inspection2.created_at).to be > inspection.created_at
        inspection3 = create(:inspection, completed_at: nil)
        expect(inspection3.created_at).to be > inspection2.created_at
        inspection4 = create(:inspection, completed_at: nil)
        expect(inspection4.created_at).to be > inspection3.created_at

        api_get :index
        expect(response.status).to eq(200)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["inspections"].length).to eq(4)
        expect(json_response["inspections"][0]["number"]).to eq(inspection.number)
        expect(json_response["inspections"][1]["number"]).to eq(inspection2.number)
        expect(json_response["inspections"][2]["number"]).to eq(inspection3.number)
        expect(json_response["inspections"][3]["number"]).to eq(inspection4.number)
      end
    end

    describe 'GET #show' do
      let(:inspection) { create :inspection, establishment_name: "Duggins Supermarket N.V."}
      subject { api_get :show, id: inspection.to_param }

      context 'when establishment information is present' do
        it 'contains establishment information on the inspection' do
          subject
          establishment = json_response['establishment']
          expect(establishment).to_not be_nil
          expect(establishment).to eq("Duggins Supermarket N.V.")
        end
      end
    end

    describe 'PUT #advance' do
      subject {api_put :advance, id:inspection.to_param}

      context 'when validation errors are present' do
        let(:inspection) { create :invalid_inspection}
        it 'returns a 409 status code in the responce' do
          subject
          expect(response.status).to eq(409)
        end
      end
    end

    it "inspections contain the basic inspection steps" do
      api_get :show, :id => inspection.to_param
      expect(response.status).to eq(200)
      expect(json_response["inspection_steps"]).to eq(["processing", "grading_and_commenting", "completed"])
    end
  end
end
