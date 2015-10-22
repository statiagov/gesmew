require 'spec_helper'

describe Gesmew::RubricAssociation do
  let(:factory_instance){Gesmew::RubricAssociation}
  let(:inspection){create(:inspection)}
  let(:scope){create(:inspection_scope)}
  let(:rubric){create(:rubric)}
  describe "self.get_association_object" do
    it "returns a valid association object" do
      association = rubric.associate_with(inspection, scope)
      params = {
        association_id: association.association_id,
        association_type: association.association_type
      }
      expect(factory_instance.get_association_object(params)).to eq(inspection)
    end
  end

  describe "#assess" do
    before do
      rubric.data = [
        {
          points: 10,
          description: 'Some Description',
          name:'Floors',
          id: 'id1',
        },
        {
          points: 10,
          description: 'Some Description',
          name:'Temperature',
          id: 'id2'
        }
      ]
    end
    let(:association) {rubric.associate_with(inspection, scope)}
    let(:assess) do
      association.assess({
        artifact:inspection,
        assessor:create(:admin_user),
        assessment: {
          criterion_id1: {
            points: 6
          },
          criterion_id2:{
            points: 7
          }
        }
      })
    end
    it 'creates an assessment' do
      expect{assess}.to change {Gesmew::RubricAssessment.count}.by(1)
    end

    it 'does not create a new assessment by the same assessor' do
      assess
      expect{assess}.to_not change{Gesmew::RubricAssessment.count}
    end
    context "when initial = true" do
      let(:assess){association.assess({}, true)}

      it 'creates and assessment' do
        expect{assess}.to change {Gesmew::RubricAssessment.count}.by(1)
      end

      it 'should have a score of 0' do
        expect(assess.score).to eq(0)
      end
    end
  end
  
end
