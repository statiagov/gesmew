require 'spec_helper'

module Gesmew
  describe Gesmew::Rubric::Updater do
    let!(:scope){create(:inspection_scope, name:'Containers')}
    let!(:rubric){create(:rubric, context:scope)}
    let!(:inspection){create(:inspection, scope:scope)}
    let(:association) {rubric.associate_with(inspection, scope)}
    let!(:assessor){create(:admin_user)}
    let(:params)do
      {
        id:scope.id,
        criteria: [
            {
              id: 'id1',
              name: "123478-OP",
              description:"The temperature should be...",
            },
            {
              id: 'id2',
              name: "Mold",
              description:"No mold!!",
            },
            {
              id: 'id3',
              name: "Extra",
              description:"Extra Extra!!",
            }
        ]
      }
    end

    before do
      rubric.data = [
        {
          description: 'Some Description',
          name:'Floors',
          id: 'id1',
        },
        {
          description: 'Some Description',
          name:'Temperature',
          id: 'id2'
        }
      ]
      rubric.save
      association.assess(
        artifact:inspection,
        assessor:assessor,
        assessment: {
          criterion_id1: {
            criterion_met: false
          },
          criterion_id2:{
            criterion_met: true
          }
        }
      )
    end
    context "adding and updating" do
      it "should update the rubric" do
        updater =  Gesmew::Rubric::Updater.new(params)
        updater.update
        rubric.reload
        expect(rubric.criteria_count).to eq(3)
      end
    end
    context "remvoing" do
      let(:params)do
        {
          id:scope.id,
          criteria: [
            {
              description: 'Some Description',
              name:'Temperature',
              id: 'id2'
            }
          ]
        }
      end
      it "should update the rubric" do
        updater =  Gesmew::Rubric::Updater.new(params)
        updater.update
        rubric.reload
        expect(rubric.criteria_count).to eq(1)
      end
    end
  end
end
