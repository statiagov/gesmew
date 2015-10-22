require 'spec_helper'

describe Gesmew::Rubric, type: :model do
  let(:scope){build(:inspection_scope)}
  let(:rubric){create(:rubric, context: scope)}

  describe "#update_criteria" do
    let(:rubric_params) do
      {
        id:rubric.id,
        title:rubric.title,
        criteria: [
          {
            points:9,
            description:"Some description",
            name:"Temperature",
          },
          {
            points:10,
            description:"Some description",
            name:'Floors',
          }
        ]
      }
    end

    it "should should save or update the rubric criteria to the database" do
      expect(rubric.points_possible).to eq(nil)
      rubric.update_criteria(rubric_params)
      expect(rubric.points_possible).to eq(19)
    end
  end

  describe "#associate_with" do
    let(:inspection){create(:inspection)}
    it "should associate an object with the rubric" do
      expect{rubric.associate_with(inspection, scope)}.to change{Gesmew::RubricAssociation.count}.from(0).to(1)
      expect(rubric.associate_with(inspection, scope)).to be_a(Gesmew::RubricAssociation)
    end
  end

  describe "#dissociate_with" do
    let(:inspection){create(:inspection)}
    before do
      rubric.associate_with(inspection, scope)
    end
    it "should dissociate an object from the rubric" do
      expect{rubric.dissociate_with(inspection, scope)}.to change{Gesmew::RubricAssociation.count}.from(1).to(0)
    end
  end
end
